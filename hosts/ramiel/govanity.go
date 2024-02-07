package main

import (
	"flag"
	"fmt"
	"log"
	"net"
	"net/http"
	"os"
	"path"
	"strings"
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
	//server := &http.Server{Handler: s}
	//flag.StringVar(&server.Addr, "addr", ":http", "http server listen addr")
	flag.StringVar(&s.BaseURL, "base-url", "", "base url")
	flag.StringVar(&s.ImportURL, "import-url", "", "import url")
	flag.Parse()
	l, err := net.Listen("unix", "/run/govanity/govanity.sock")
	if err != nil {
		log.Fatalln(err)
	}
	if err := os.Chmod("/run/govanity/govanity.sock", 0777); err != nil {
		log.Fatalln(err)
	}
	log.Fatalln(http.Serve(l, s))
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
