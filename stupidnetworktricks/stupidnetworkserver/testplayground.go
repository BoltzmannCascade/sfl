package main

import (
   "flag"
   "fmt"
   "net/http"

   "github.com/garyburd/redigo/redis"
)

var (
    cacheAddress = flag.String("cache-address", ":6739", "Address to the cache server")
    maxConnections = flag.Int("cache-connection-limit", 10, "Cache connection limit")
)

func handler(w http.ResponseWriter, r *http.Request) {
    fmt.Println(r.Header)    
    fmt.Fprintf(w, "{\"events\":[{\"name\":\"Ironman Maryland\", \"date\":\"2016-10-01T07:00:00-00:00\", \"motto\":\"A backup plan is for the faint of heart\", \"type\":\"ironman\"},{\"name\":\"Ironman 70.3 Canada\", \"date\":\"2016-07-24T07:00:00-00:00\", \"motto\":\"Keep Pushing\", \"type\":\"ironman70_3\"}]}") 
}

func main() {
    fmt.Println("Server is starting...")
    
    cachePool := redis.NewPool(func()(redis.Conn, error) {
    	fmt.Println("Cache is starting...")
	c, err := redis.Dial("tcp", *cacheAddress)
	if(err != nil){
		fmt.Println("Unable to open redis cache")
		return nil, err
	}

	return c, err
     }, *maxConnections)

     defer cachePool.Close();

     http.HandleFunc("/", handler)
     http.ListenAndServe(":8080", nil)
}
