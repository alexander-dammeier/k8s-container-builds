package main

import (
	_ "embed"
	"fmt"
	"html/template"
	"net/http"
)

//go:embed index.html
var htmlContent string

// BuildTime is injected during the build process using -ldflags
var BuildTime = "Unknown"

func main() {
	tmpl := template.Must(template.New("index").Parse(htmlContent))

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		data := struct {
			BuildTime string
		}{
			BuildTime: BuildTime,
		}
		tmpl.Execute(w, data)
	})

	fmt.Println("Server starting on :8080...")
	if err := http.ListenAndServe(":8080", nil); err != nil {
		panic(err)
	}
}
