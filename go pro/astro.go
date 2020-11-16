package main

import (
    "encoding/json"
    "fmt"
    "io/ioutil"
    "log"
    "net/http"
    "time"
)

type Astronaut struct {
    Name  string
    Craft string
}

type people struct {
    Number  int
    People  []Astronaut
    Message string
}

func main() {

    url := "http://api.open-notify.org/astros.json"

    var netClient = http.Client{
        Timeout: time.Second * 10,
    }

    res, err := netClient.Get(url)

    if err != nil {
        log.Fatal(err)
    }

    defer res.Body.Close()

    body, err := ioutil.ReadAll(res.Body)

    fmt.Println(body)

    if err != nil {
        log.Fatal(err)
    }

    astros := people{}

    jsonErr := json.Unmarshal(body, &astros)

    if jsonErr != nil {
        log.Fatal(jsonErr)
    }

    fmt.Println(astros)
}
