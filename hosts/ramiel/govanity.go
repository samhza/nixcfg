package main

import (
	"flag"
	"fmt"
	"log"
	"net/http"
	"path"
	"strings"
	"time"
)

type server struct {
	BaseURL   string
	ImportURL string
}

func init() {
	log.SetFlags(0)
}

func main() {
	s := &server{}
	server := &http.Server{Handler: s}
	timeout := flag.Int("timeout", 15, "http server read timeout in seconds")
	flag.StringVar(&server.Addr, "addr", ":http", "http server listen addr")
	flag.StringVar(&s.BaseURL, "base-url", "", "base url")
	flag.StringVar(&s.ImportURL, "import-url", "", "import url")
	flag.Parse()
	server.ReadTimeout = time.Duration(*timeout) * time.Second
	log.Fatalln(server.ListenAndServe())
}

func (s *server) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	path := path.Clean(r.URL.Path)
	if split := strings.Split(r.URL.Path, "/"); len(split) == 1 {
		path = split[0]
	} else {
		path = split[1]
	}
	fmt.Fprintf(w, `<meta name="go-import" content="%s/%s %s/%s">`,
		s.BaseURL, path, s.ImportURL, path)
}
