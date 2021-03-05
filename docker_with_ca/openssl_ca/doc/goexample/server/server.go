package main

import (
	"io"
	"log"
	"net/http"
)

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, req *http.Request) {
		io.WriteString(w, "hello, world!\n")
	})
	if e := http.ListenAndServeTLS("0.0.0.0:1180", "/home/ao/Documents/certs/review/server.crt",
		"/home/ao/Documents/certs/review/server.key", nil); e != nil {
		log.Fatal("ListenAndServe: ", e)
	}
	//if e := http.ListenAndServe("0.0.0.0:5200", nil); e != nil {
	//    log.Fatal("ListenAndServe: ", e)
	//}

	//err := http.ListenAndServe(":1180", nil)
	//if err != nil {
	//	log.Fatal("ListenAndServe: ", err)
	//}
}
