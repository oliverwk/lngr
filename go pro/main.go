package main

import (
    "fmt"
    "io/ioutil"
    "log"
    "net/http"
    "os"
    "encoding/json"
)

type Response struct {
    Lingerie []Lingerie `json`
}

type Lingerie struct {
    prijs string   `json:"prijs"`
    img_url string `json:"img_url"`
    naam string `json:"naam"`
}

func mainer() {
    response, err := http.Get("https://raw.githubusercontent.com/oliverwk/wttpknng/master/Lingerie.json")

    if err != nil {
        fmt.Print(err.Error())
        os.Exit(1)
    }

    responseData, err := ioutil.ReadAll(response.Body)
    if err != nil {
        log.Fatal(err)
    }
    fmt.Println(string(responseData))

    var responseObject Response
    json.Unmarshal(responseData, &responseObject)

    fmt.Println(len(responseObject.Lingerie))

    for i := 0; i < len(responseObject.Lingerie); i++ {
      fmt.Println("responseObject.Lingerie[i].naam")
      fmt.Println(responseObject.Lingerie[i].naam)
      fmt.Println(responseObject.Lingerie[i].naam)
    }
}

func main() {

	client := http.Client{}
	request, err := http.NewRequest("GET", "https://raw.githubusercontent.com/oliverwk/wttpknng/master/Lingerie.json", nil)
	if err != nil {
		log.Fatalln(err)
	}

	resp, err := client.Do(request)
	if err != nil {
		log.Fatalln(err)
	}

	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)
	log.Println(result["data"])
}
