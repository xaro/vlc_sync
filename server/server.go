package main

import "fmt"
import "os"
import "io/ioutil"
import "net/http"

func handler(w http.ResponseWriter, r *http.Request) {
  client := &http.Client{}

  vlcPort := r.URL.Query()["vlcPort"][0]

  // Call the VLC URL with the same parameters we got
  vlcRequest, err := http.NewRequest("GET", "http://localhost:" + vlcPort + "/requests/status.json?" + r.URL.RawQuery, nil)
  vlcRequest.SetBasicAuth("", "vlc")
  vlcResponse, err :=  client.Do(vlcRequest)

  if err != nil {
    fmt.Printf("%s", err)
    os.Exit(1)
  } else {
    defer vlcResponse.Body.Close()

    // Read all the contents from the VLC API
    contents, _ := ioutil.ReadAll(vlcResponse.Body)
    if err != nil {
      fmt.Printf("%s", err)
      os.Exit(1)
    } else {
      // Ensure cross-origin calls are allowed
      w.Header().Set("Access-Control-Allow-Origin", "*")

      fmt.Fprint(w, string(contents))
    }
  }
}

func main() {
  http.HandleFunc("/status", handler)
  http.ListenAndServe(":9393", nil)
}