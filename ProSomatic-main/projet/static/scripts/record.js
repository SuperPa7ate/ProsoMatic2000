// https://blog.addpipe.com/using-webaudiorecorder-js-to-record-audio-on-your-website/
// using WebAudioRecorder.js : https://github.com/higuma/web-audio-recorder-js

// audio data is recorded as 2 channel 16bit audio (CD quality) and thus will be exactly 10.582MB/minute at 44.1kHz but you can lower the number of channels.

// SAMPLING RATE
// Regardless of the library, the sample rate used will be the one set in your OS for your playback device (as per the spec). In practice, you’ll mostly see sample rates of 44100 (44.1kHz) and 48000 (48kHz).

//webkitURL is deprecated but nevertheless
URL = window.URL || window.webkitURL;

var gumStream; 						//stream from getUserMedia()
var recorder; 						//WebAudioRecorder object
var input; 							//MediaStreamAudioSourceNode  we'll be recording
var encodingType; 					//holds selected encoding for resulting audio (file)
var encodeAfterRecord = true;       // when to encode

// shim for AudioContext when it's not avb. 
var AudioContext = window.AudioContext || window.webkitAudioContext;
var audioContext ; //new audio context to help us record

var encodingTypeSelect = document.getElementById("encodingTypeSelect");
var recordButton = document.getElementById("recordButton");
var stopButton = document.getElementById("stopButton");

//add events to those 2 buttons
recordButton.addEventListener("click", startRecording);
stopButton.addEventListener("click", stopRecording);

var myblob;
var myblobSampleRate;


function startRecording() {
	console.log("Recording...");

	/*
		Simple constraints object, for more advanced features see
		https://addpipe.com/blog/audio-constraints-getusermedia/
	*/
    
    var constraints = {
        audio: true,
        video: false
    }

    /*
    	We're using the standard promise based getUserMedia() 
    	https://developer.mozilla.org/en-US/docs/Web/API/MediaDevices/getUserMedia
	*/

	navigator.mediaDevices.getUserMedia(constraints).then(function(stream) {
		__log("getUserMedia() success, stream created, initializing WebAudioRecorder...");

		/*
			create an audio context after getUserMedia is called
			sampleRate might change after getUserMedia is called, like it does on macOS when recording through AirPods
			the sampleRate defaults to the one set in your OS for your playback device
		*/
		audioContext = new AudioContext();
        myblobSampleRate = audioContext.sampleRate;
		//update the format 
		document.getElementById("formats").innerHTML="Format: 2 channel "+encodingTypeSelect.options[encodingTypeSelect.selectedIndex].value+" @ "+audioContext.sampleRate/1000+"kHz"

		//assign to gumStream for later use
		gumStream = stream;
		
		/* use the stream */
		input = audioContext.createMediaStreamSource(stream);
		
		//stop the input from playing back through the speakers
		//input.connect(audioContext.destination)

		//get the encoding 
		encodingType = encodingTypeSelect.options[encodingTypeSelect.selectedIndex].value;
		
		//disable the encoding selector
		encodingTypeSelect.disabled = true;

		recorder = new WebAudioRecorder(input, {
			workerDir: "scripts/", // must end with slash
			encoding: encodingType,
			numChannels:2, //2 is the default, mp3 encoding supports only 2
			
			onEncoderLoading: function(recorder, encoding) {
				// show "loading encoder..." display
				__log("Loading "+encoding+" encoder...");
			},
			
			onEncoderLoaded: function(recorder, encoding) {
				// hide "loading encoder..." display
				__log(encoding+" encoder loaded");
			}
			});

		recorder.onComplete = function(recorder, blob) { 
			__log("Encoding complete");
			createDownloadLink(blob,recorder.encoding);
            myblob = blob;
			encodingTypeSelect.disabled = false;
		}

		recorder.setOptions({
		  timeLimit:60,
		  encodeAfterRecord:encodeAfterRecord,
	      ogg: {quality: 0.5},
	      mp3: {bitRate: 160}
	    });

		//start the recording process
		recorder.startRecording();

		 __log("Recording started");

	}).catch(function(err) {
	  	//enable the record button if getUSerMedia() fails
    	recordButton.disabled = true;
    	stopButton.disabled = false;

	});

	//disable the record button
    recordButton.disabled = true;
    stopButton.disabled = false;
}

function stopRecording() {
	console.log("Stop recording.");
	
	//stop microphone access
	gumStream.getAudioTracks()[0].stop();

	//disable the stop button
	stopButton.disabled = false;
	recordButton.disabled = true;
	
	//tell the recorder to finish the recording (stop recording + encode the recorded audio)
	recorder.finishRecording();

	__log('Recording stopped');
}


function createDownloadLink(blob,encoding) {
	
	var url = URL.createObjectURL(blob);
	var au = document.createElement('audio');
	var li = document.createElement('li');
	var link = document.createElement('a');

	//add controls to the <audio> element
	au.controls = true;
	au.src = url;

	//link the a element to the blob
	link.href = url;
	link.download = new Date().toISOString() + '.'+encoding;
	link.innerHTML = link.download;
    link.style.display = 'none';

	//add the new audio and a elements to the li element
	li.appendChild(au);
	li.appendChild(link);

	//add the li element to the ordered list
    recordingsList.innerHTML = ""; // on réinitialise la liste ici
	recordingsList.appendChild(li);

    // activate button save!
    document.getElementById('comparer').disabled = false;
    
}



//helper function
function __log(e, data) {
	log.innerHTML += "\n" + e + " " + (data || '');
}


// ENREGISTRER LE FICHIER SUR LE SERVEUR

// https://www.codegrepper.com/code-examples/javascript/javascript+stringify+blob
const blobToBase64 = (blob) => {
    return new Promise((resolve) => {
      const reader = new FileReader();
      reader.readAsDataURL(blob);
      reader.onloadend = function () {
        resolve(reader.result);
      };
    });
};
async function addRec() {

    // CONVERT BLOB TO BASE64
    const b64 = await blobToBase64(myblob);

    var colis = {
        'user': user,
        'session': session,
        'questionnaire': questionnaire,
        'sampleRate': myblobSampleRate,
        'audio': b64.replace(/^data:.+;base64,/, '')
    }


    // Paramètres d'envoi
    const options = {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(colis)
    }
    
    // ENVOI
	// L'envoie permet au fichier enregistré par l'apprenant de le sauvegarder sur le serveur. 
    try {
        document.getElementById('actionBlock').style.display = 'block'
        const response = await fetch('/rec/test1/', options)
        const data = await response.json()
        document.getElementById('actionBlock').style.display = 'none'
        window.alert('Saved!')
        console.log("Envoi du fichier réussi")
    } catch (error) {
        document.getElementById('actionBlock').style.display = 'none'
        window.alert('Erreur. Enregistrement trop volumineux ? (limite:10Mo)\nDétails: '+error.message)
    }
}
// Une fois que l'apprenant appuie sur le bouton comparer, le fichier est sauvegardé dans le repertoire /rec/test1 au format .wav
$('#comparer').on('click', function(){
    var btn = $(this);
    btn.html('Saving...').prop('disabled', true);
    var myFile = new File([player.recordedData], 'audio.webm');
    var csrf = $('input[name="csrfmiddlewaretoken"]').val();
    var url = "{% url 'Rec' %}";
    var data = new FormData();
    data.append('recorded_audio', myFile);
    data.append('csrfmiddlewaretoken', csrf);
    $.ajax({
        url: url,
        method: 'post',
        data: data,
        success: function(data){
            if(data.success){
                btn.html('Saved!');
                //$('.upload-comp').show();
            }
            else{
                btn.html('Error').prop('disabled', false);
            }
        },
        cache: false,
        contentType: false,
        processData: false
    });
});
// Une fois que le fichier est sauvegardé dans le repertoire, alors le script praat peut le récuperer pour le comparer à l'exemple.
