package main

import (
	"fmt"
	"io/ioutil"
	"net/http"
	"os"

	log "github.com/sirupsen/logrus"
)

var results []string

func main() {
	// use PORT environment variable, or default to 8080
	port := "7888"
	if fromEnv := os.Getenv("PORT"); fromEnv != "" {
		port = fromEnv
	}

	// register hello function to handle all requests
	server := http.NewServeMux()

	server.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		log.Printf("Serving request: %s", r.URL.Path)
		fmt.Fprintf(w, "Hello")
	})

	server.HandleFunc("/ping", hello)
	server.HandleFunc("/event", event)
	// start the web server on port and accept requests
	log.Printf("Server listening on port %s", port)
	err := http.ListenAndServe(":"+port, server)
	log.Fatal(err)
}

func event(w http.ResponseWriter, r *http.Request) {
	if r.Method == "POST" {
		body, err := ioutil.ReadAll(r.Body)
		if err != nil {
			http.Error(w, "Error reading request body", http.StatusInternalServerError)
		}
		results = append(results, string(body))
		fmt.Fprint(w, "POST done")
	} else if r.Method == "GET" {
		fmt.Fprintf(w, "OK")
	}
	return
}

// ping responds to the request with a plain-text "Ok" message.
func hello(w http.ResponseWriter, r *http.Request) {
	log.Printf("Serving request: %s", r.URL.Path)
	fmt.Fprintf(w, "Ok")
}
