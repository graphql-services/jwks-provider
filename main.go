package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"

	"github.com/google/uuid"
)

// https://auth0.com/docs/quickstart/backend/golang/01-authorization

func main() {
	keyID := uuid.New().String()
	rsaKey, err := generateNewRSAKey()
	if err != nil {
		panic(err)
	}

	http.HandleFunc("/.well-known/jwks.json", jwksHandler(&rsaKey.PublicKey, keyID))
	http.HandleFunc("/private/jwks.json", jwksHandler(rsaKey, keyID))
	http.HandleFunc("/healthcheck", func(w http.ResponseWriter, r *http.Request) {
		json.NewEncoder(w).Encode(map[string]string{"status": "OK"})
	})

	port := os.Getenv("PORT")
	if port == "" {
		port = "80"
	}
	log.Fatal(http.ListenAndServe(":"+port, nil))
}
