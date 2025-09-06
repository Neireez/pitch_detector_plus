/*
The MIT License (MIT)
Copyright (c) 2014 Chris Wilson
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

window.AudioContext = window.AudioContext || window.webkitAudioContext;

var audioContext = null;
var analyser = null;
var mediaStreamSource = null;
var buflen = 2048;
var buf = new Float32Array( buflen );
var rafID = null;
var callback = null;

window.onload = function() {
	audioContext = new AudioContext();
	MAX_SIZE = Math.max(4,Math.floor(audioContext.sampleRate/5000));
}

function startPitchDetect(_callback) {
    // grab an audio context
	callback = _callback;
	console.log(callback);
	console.log(audioContext.sampleRate);
    audioContext = new AudioContext();

    // Attempt to get audio input
    navigator.mediaDevices.getUserMedia(
    {
        "audio": {
            "mandatory": {
                "googEchoCancellation": "false",
                "googAutoGainControl": "false",
                "googNoiseSuppression": "false",
                "googHighpassFilter": "false"
            },
            "optional": []
        },
    }).then((stream) => {
        // Create an AudioNode from the stream.
        mediaStreamSource = audioContext.createMediaStreamSource(stream);

	    // Connect it to the destination.
	    analyser = audioContext.createAnalyser();
	    analyser.fftSize = 2048;
	    mediaStreamSource.connect( analyser );
	    updatePitch();
    }).catch((err) => {
        // always check for errors at the end.
        console.error(`${err.name}: ${err.message}`);
        alert('Stream generation failed.');
    });
}

function stopRecording(){
	analyser = null;
	if (!window.cancelAnimationFrame)
		window.cancelAnimationFrame = window.webkitCancelAnimationFrame;
	window.cancelAnimationFrame( rafID );
}

function updatePitch( time) {
	var cycles = new Array;
	analyser.getFloatTimeDomainData( buf );
	if(callback !== null){
		callback(buf);
	}
	rafID = window.requestAnimationFrame( updatePitch );	
}

function getSampleRate(){
    return audioContext.sampleRate;
}