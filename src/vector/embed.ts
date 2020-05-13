window.Matrix = {
    calls: window.Matrix || [],
    push: function (x) {
        window.Matrix.calls.push(x);
    },
};

typeof window.Matrix !== 'undefined' && window.Matrix.init || function (win, doc) {

    //// PRIVATE ////

    win.Matrix.helper = {
        setPublicPath(assetDomain) {
            win.matrixPublicPath = assetDomain;
        },

        createRiotDomElement(options) {
            const riotBox = doc.createElement('section');
            riotBox.id = 'matrixchat';
            riotBox.dataset.vectorIndexeddbWorkerScript = options.indexeddbWorkerScript;
            riotBox.dataset.vectorConfig = options.riotConfig || '';
            riotBox.dataset.vectorDefaultToggled = options.defaultToggled === true ? 'true' : 'false';
            riotBox.dataset.vectorForceToggled = options.forceToggled === true ? 'true' : '';
            riotBox.dataset.matrixLang = options.language || '';
            riotBox.dataset.matrixRoomId = options.roomId || '';
            riotBox.dataset.matrixHomeserverUrl = options.homeserverUrl || '';
            riotBox.dataset.matrixUserId = options.userId || '';
            riotBox.dataset.matrixAccessToken = options.accessToken || '';
            riotBox.dataset.matrixDeviceId = options.deviceId || '';
            doc.body.appendChild(riotBox);
        },

        loadBundleScript(assetDomain, hash) {
            const riotScript = doc.createElement('script');
            riotScript.src = `${assetDomain}bundles/${hash}/bundle.js`;
            riotScript.type = 'text/javascript';
            doc.head.appendChild(riotScript);
        },
    };

    //// PUBLIC ////

    // const options = {
    // 		riotConfig: '/config.json',
    // 		indexeddbWorkerScript: '/indexeddb-worker.js',
    // 		assetDomain: 'https://cdn.domain/,
    // 		language: 'de',                         // (optional)
    // 		forceToggled: true,                     // (optional)
    // 		roomId: '#xxxx:servername',             // (optional)
    // 		homeserverUrl: 'https://matrix.domain', // (optional if already in localstorage)
    // 		userId: '@xxxx:servername',             // (optional if already in localstorage)
    // 		accessToken: 'xxxx',                    // (optional if already in localstorage)
    // 		deviceId: 'xxxx',                       // (optional if already in localstorage)
    // }
    win.Matrix.setup = function (options) {
        win.Matrix.helper.setPublicPath(options.assetDomain);
        win.Matrix.helper.createRiotDomElement(options);
        win.Matrix.helper.loadBundleScript(options.assetDomain, win.matrixHash);
    };

    //// SETUP ////

    // call executor
    win.Matrix.push = function (call) {
        const func = call[0];
        const options = call.slice(1);

        if ('function' === typeof win.Matrix[func]) {
            win.Matrix[func].apply(null, options);
        }
    };

    win.Matrix.init = function () {
        for (let Z = 0; Z < win.Matrix.calls.length; Z++) {
            win.Matrix.push(win.Matrix.calls[Z]);
        }
    };

    if (doc.readyState === 'complete') {
        win.Matrix.init();
    } else {
        win.onload = win.Matrix.init;
    }

}(window, document);
