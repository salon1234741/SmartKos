#include <WiFi.h>
#include <WebServer.h>
#include <LittleFS.h>
#include <PubSubClient.h>
#include <WiFiClientSecure.h>
#include <Time.h>

const char* ssid     = "KOS KEJAWAN 24";
const char* password = "boardinghouse";

const int kipas  = 5;
const int led    = 23;
const int buzzer = 19;
const int button = 18;

const char* hostMQTT  = "276d9e54084e4a99b7b863492b06212b.s1.eu.hivemq.cloud";
const int   portMQTT  = 8883;
const char* userMQTT  = "Rafifirdaus";
const char* passMQTT  = "@Gresik123";
const char* topicLampu = "smartkos/lampu";
const char* topicAlarm = "smartkos/alarm";
const char* topicKipas = "smartkos/kipas";

int     homeAlarmJam   = -1;
int     homeAlarmMenit = -1;
bool    homeAlarmAktif = false;

int     schAlarmJam    = -1;
int     schAlarmMenit  = -1;
bool    schAlarmAktif  = false;

bool    buzzerNyala = false;

WiFiClientSecure espClient;
PubSubClient     mqtt(espClient);
WebServer        server(80);

void callback(char* topic, byte* payload, unsigned int length) {
  String pesan = "";
  for (unsigned int i = 0; i < length; i++) pesan += (char)payload[i];
  Serial.println("Pesan [" + String(topic) + "]: " + pesan);

  if (String(topic) == topicKipas) {
    if      (pesan == "ON")  digitalWrite(kipas, LOW);
    else if (pesan == "OFF") digitalWrite(kipas, HIGH);
  }
  else if (String(topic) == topicLampu) {
    if      (pesan == "ON")  digitalWrite(led, HIGH);
    else if (pesan == "OFF") digitalWrite(led, LOW);
  }
  else if (String(topic) == topicAlarm) {
    if (pesan == "HOME_OFF") {
      homeAlarmAktif  = false;
      homeAlarmJam    = -1;
      homeAlarmMenit  = -1;
      if (!schAlarmAktif) { buzzerNyala = false; digitalWrite(buzzer, LOW); }
      Serial.println("Home Alarm dinonaktifkan");
    }
    else if (pesan == "SCH_OFF") {
      schAlarmAktif  = false;
      schAlarmJam    = -1;
      schAlarmMenit  = -1;
      if (!homeAlarmAktif) { buzzerNyala = false; digitalWrite(buzzer, LOW); }
      Serial.println("Schedule Alarm dinonaktifkan");
    }
    else if (pesan.startsWith("HOME_")) {
      homeAlarmJam   = pesan.substring(5, 7).toInt();
      homeAlarmMenit = pesan.substring(8, 10).toInt();
      homeAlarmAktif = true;
      Serial.println("Home Alarm diset: " + pesan);
    } 
    else if (pesan.startsWith("SCH_")) {
      schAlarmJam    = pesan.substring(4, 6).toInt();
      schAlarmMenit  = pesan.substring(7, 9).toInt();
      schAlarmAktif  = true;
      Serial.println("Schedule Alarm diset: " + pesan);
    }
    else if (pesan == "OFF") {
      // Fallback: disable both
      homeAlarmAktif = false; schAlarmAktif = false;
      buzzerNyala = false; digitalWrite(buzzer, LOW);
    }
  }
}

unsigned long lastMqttReconnect = 0;

boolean reconnect() {
  Serial.print("Konek MQTT...");
  if (mqtt.connect("Smart Kos Ropiul", userMQTT, passMQTT)) {
    Serial.println("Terhubung!");
    mqtt.subscribe(topicLampu);
    mqtt.subscribe(topicAlarm);
    mqtt.subscribe(topicKipas);
    return true;
  } else {
    Serial.print("Gagal, rc=");
    Serial.println(mqtt.state());
    return false;
  }
}

void website() {
  File file = LittleFS.open("/index.html", "r");
  if (!file) { server.send(404, "text/plain", "File tidak ditemukan"); return; }
  server.streamFile(file, "text/html");
  file.close();
}

void setup() {
  Serial.begin(115200);
  pinMode(kipas,  OUTPUT);
  pinMode(led,    OUTPUT);
  pinMode(buzzer, OUTPUT);
  pinMode(button, INPUT_PULLUP);
  digitalWrite(led,    LOW);
  digitalWrite(buzzer, LOW);
  digitalWrite(kipas,  LOW);

  if (!LittleFS.begin()) {
    Serial.println("LittleFS gagal mount");
    return;
  }

  WiFi.begin(ssid, password);
  Serial.print("Connecting WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(100);
    Serial.print(".");
  }
  Serial.println("\nWiFi Connected: " + WiFi.localIP().toString());

  configTime(7 * 3600, 0, "pool.ntp.org", "time.nist.gov");
  Serial.print("Sync NTP");
  struct tm timeinfo;
  while (!getLocalTime(&timeinfo)) {
    Serial.print(".");
    delay(500);
  }
  Serial.printf("\nWaktu: %02d:%02d\n", timeinfo.tm_hour, timeinfo.tm_min);

  espClient.setInsecure();
  mqtt.setBufferSize(1024);
  mqtt.setServer(hostMQTT, portMQTT);
  mqtt.setCallback(callback);

  server.on("/", website);
  server.begin();
}

void loop() {
  if (!mqtt.connected()) {
    unsigned long now = millis();
    if (now - lastMqttReconnect > 5000 || lastMqttReconnect == 0) {
      lastMqttReconnect = now;
      if (reconnect()) {
        lastMqttReconnect = 0;
      }
    }
  } else {
    mqtt.loop();
  }
  
  server.handleClient();

  // Tombol fisik: matikan buzzer dan nonaktifkan alarm yang sedang berbunyi
  if (digitalRead(button) == LOW && buzzerNyala) {
    buzzerNyala = false;
    homeAlarmAktif = false;
    schAlarmAktif = false;
    digitalWrite(buzzer, LOW);
    Serial.println("Alarm dimatikan via tombol");
  }

  // Cek waktu alarm
  struct tm timeinfo;
  if (getLocalTime(&timeinfo) && !buzzerNyala) {
    bool triggerHome = (homeAlarmAktif && timeinfo.tm_hour == homeAlarmJam && timeinfo.tm_min == homeAlarmMenit);
    bool triggerSch  = (schAlarmAktif && timeinfo.tm_hour == schAlarmJam && timeinfo.tm_min == schAlarmMenit);
    
    if (triggerHome || triggerSch) {
      buzzerNyala = true;
      digitalWrite(buzzer, HIGH);

      if (triggerHome) {
        // Alarm Home: buzzer ON + kipas OFF
        digitalWrite(kipas, HIGH);
        mqtt.publish("smartkos/status", "ALARM_HOME_BUNYI");
        Serial.println("Home Alarm berbunyi!");
      } else {
        // Alarm Schedule: buzzer ON + kipas tetap ON
        digitalWrite(kipas, LOW);
        mqtt.publish("smartkos/status", "ALARM_SCH_BUNYI");
        Serial.println("Schedule Alarm berbunyi!");
      }
    }
  }
}
