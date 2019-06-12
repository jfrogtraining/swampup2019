package main

import (
	"github.com/labstack/echo"
	"math/rand"
	"net/http"
	"time"
)

var frogFacts =  []string {
	"There are over 5,000 species of frog" ,
	"Frogs don’t need to drink water as they absorb it through their skin",
	"A frog’s call is unique to its species, and some frog calls can be heard up to a mile away",
	"Some frogs can jump over 20 times their own body length; that is like a human jumping 30m",
	"Due to their permeable skin, typically biphastic life (aquatic larvae and terrestrial adults), and mid-position in the food web frogs and other amphibians are excellent biological indicators of the wider health of ecosystems",
	"In Egypt the frog is the symbol of life and fertility, and in Egyptian mythology Heget is a frog-goddess who represents fertility",
}



func main() {
	e := echo.New()
	e.GET("/", func(c echo.Context) error {
		time.Sleep(time.Second * 7)
		n := rand.Int() % len(frogFacts)
		return c.String(http.StatusOK, frogFacts[n])
	})
	e.Logger.Fatal(e.Start(":3000"))
}