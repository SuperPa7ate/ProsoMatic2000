from django.views.generic import TemplateView
from django.shortcuts import render
import json, base64, wave, datetime

# Create your views here.

def home(request) :
    return render(request,'home.html')

def contact(request) :
    return render(request, 'contact.html')

def aide(request) :
    return render(request,'aide.html')

def commencer(request) :
    return render(request, 'commencer.html')

def test1(request):
    return render(request, 'test1.html')

def addRec(request):
    colis = json.loads(request.body)
    
    fname = f"../media/prosophone/enregistrements/session{colis['session']}-item{colis['questionnaire']}-user{colis['user']}_{ datetime.datetime.now().strftime('%Y-%m-%d_%H:%M:%S') }.wav" 

    with wave.open(fname,'w') as outf:
        outf.setnchannels(2)
        outf.setsampwidth(2)
        outf.setframerate(colis['sampleRate'])
        outf.writeframes(base64.b64decode(colis['audio']))

    data= {
        'saved': True
    }
    return json.response(data)



