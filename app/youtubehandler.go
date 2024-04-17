package main

import (
	"encoding/json"
	"github.com/julienschmidt/httprouter"
	"net/http"
)

type YoutubeStats struct {
	YoutubeKey  string `json:"subscribers"`
	ChannelName string `json:"channelName"`
}

func getChannelStats(k string, channelID string) httprouter.Handle {
	return func(w http.ResponseWriter, r *http.Request, ps httprouter.Params) {
		yt := YoutubeStats{
			YoutubeKey:  k,
			ChannelName: channelID,
		}

		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		if err := json.NewEncoder(w).Encode(yt); err != nil {
			panic(err)
		}
	}
}
