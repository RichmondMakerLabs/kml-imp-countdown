

// Countdown

local bustop = "56822";	// Ashburnham Road to Kingston

local tflURL = "http://countdown.tfl.gov.uk/stopBoard/"+bustop+"/";


function getBusTimes() {
    server.log(format("Getting data for stop: %s", bustop));
        // call http.get on our new URL to get an HttpRequest object. Note: we're not using any headers
   // server.log(format("Sending request to %s", tflURL));
    local req = http.get(tflURL);

    // send the request synchronously (blocking). Returns an HttpMessage object.
    local res = req.sendsync();

    // check the status code on the response to verify that it's what we actually wanted.
    //server.log(format("Response returned with status %d", res.statuscode));
    if (res.statuscode != 200) {
        server.log("Request failed.");
        imp.wakeup(30, getBusTimes);
        return;
    }

    // log the body of the message and find out what we got.
    // server.log(res.body);

    // hand off data to be parsed
    local response = http.jsondecode(res.body);
    local bus = response.arrivals;
    local busString = "";
    
    // Chunk together our forecast into a printable string
    busString += ("Next "+bus[0].routeName+" ");
    busString += ("to "+bus[0].destination+" ");
    busString += ("is "+bus[0].estimatedWait+" ");

    // relay the formatting string to the device
    // it will then be handled with function registered with "agent.on":
    // agent.on("newData", function(data) {...});
    server.log(format("Sending result to imp: %s",busString));
    device.send("newData", busString);
        
    imp.wakeup(30, getBusTimes);
}

imp.sleep(2);
getBusTimes();
