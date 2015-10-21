'use strict';

describe("config file", function() {

    it("erizoController port and publicIP are set", function() {
        expect(config.erizoController.port).toBe(8080);
        expect(config.erizoController.publicIP).toBeDefined()
    });

});
