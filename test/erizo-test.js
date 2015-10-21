'use strict';

describe('server', function () {
    var room;

    // room states
    var DISCONNECTED = 0,
    CONNECTING = 1,
    CONNECTED = 2;

    var videoStreamConfig = {audio: false, video: false, data: false, videoSize: [640, 480, 640, 480]};

    beforeAll(function() {
        // modify jasmine timeout to be 30 seconds
        jasmine.DEFAULT_TIMEOUT_INTERVAL = 30000;
    });

    it('should connect to room', function(done) {

        var room_token = JSON.stringify({
            "id": "mock-session-token",
            "host": config.erizoController.publicIP + ':' + config.erizoController.port,
            "secure": false
        });

        room = Erizo.Room({token: room_token});
        expect(room.state).toBe(DISCONNECTED);

        room.addEventListener("room-connected", function(roomEvent) {
            expect(room.state).toBe(CONNECTED);
            done();
        });

        room.connect();
        expect(room.state).toBe(CONNECTING);
    });

    it('should disconnect from room', function(done) {

        expect(room.state).toBe(CONNECTED);

        room.addEventListener("room-disconnected", function(roomEvent) {
            expect(room.state).toBe(DISCONNECTED);
            done();
        });

        room.disconnect();
    });

    it('should connect and record', function(done) {

        var room_token = JSON.stringify({
            "id": "mock-session-token",
            "host": config.erizoController.publicIP + ':' + config.erizoController.port,
            "secure": false
        });

        videoStreamConfig.video = true;
        var localStream = Erizo.Stream(videoStreamConfig);

        localStream.addEventListener("access-accepted", function () {
            expect(localStream.stream).toBeDefined();
            // connect will fire room-connected on success
            room.connect();
        });

        room = Erizo.Room({token: room_token});

        room.addEventListener("room-connected", function(roomEvent) {
            expect(room.state).toBe(CONNECTED);
            // publish will fire the stream-added event on success
            room.publish(localStream, {maxVideoBW: 3000});
        });

        room.addEventListener("stream-added", function (streamEvent) {
            room.startRecording(localStream, function(id) {

                // use setTimeout to wait 20 seconds, then stop recording
                setTimeout(function() {
                    room.stopRecording(function(success, error) {
                        done();
                    });
                }, 20000);
            });
        });

        // init will fire access-accepted on success
        localStream.init();

    });

    it('should accept access to local stream with video', function(done) {

        videoStreamConfig.video = true;
        var localStream = Erizo.Stream(videoStreamConfig);

        localStream.addEventListener("access-accepted", function () {
            expect(localStream.stream).toBeDefined();

            done();
        });

        localStream.init();
    });

    it('should deny access to when trying to stream with screen', function(done) {

        videoStreamConfig.screen = true;
        var localStream = Erizo.Stream(videoStreamConfig);

        localStream.addEventListener("access-denied", function () {
            expect(localStream.stream).toBeUndefined();

            done();
        });

        localStream.init();
    });

});
