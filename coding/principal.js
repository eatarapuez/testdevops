const express = require("express");
const app = express();
app.engine('html', require('ejs').renderFile);
//definen objetos necesarios para la construcción
const puerto = 5000;
const path = require('path'); 
const bodyParser = require('body-parser');
app.use(bodyParser.urlencoded({extended: false}));
app.use(express.static(__dirname + '/'));
//base de datos de usuarios
var users = [
    {
        "alejandro":"pass",
        "daniel":"pass2",
        "eduardo":"pass3",
        "stefania":"pass4",
        "tobi":"pass5"
    }
];
var message = ""
var boton = "enabled"
var cont = 3
app.get('/', (req,res)=>{
    res.render(__dirname + "/formulario.html", {message:message,boton:boton});
});

app.post('/', (req,res)=>{
    console.log(req.body.user)

    if(req.body.user && req.body.pass){
        if(users[0][req.body.user]){
            if(users[0][req.body.user]==req.body.pass){
                message = "Ha ingresado correctamente"
            }else{
                cont = cont - 1;
                message = "contraseña incorrecta \n"+cont+" intentos restantes"
                if(cont==0){
                    message = "Sistema bloqueado espere 30 segundos"
                    boton = "disabled"
                    res.render(__dirname + "/formulario.html", {message:message,boton:boton});                    
                    setTimeout(() => { 
                        boton = "enabled"
                        console.log("finalizo");
                        message = "Intente nuevamente"
                     }, 10000);   
                     cont = 3;                 
                }
            }
        }else{
            message = "El usuario "+req.body.user+" no existe"
        }
    }else{
        message = "Todos los campos son obligatorios"
    }
    if(boton == "enabled"){
        res.render(__dirname + "/formulario.html", {message:message,boton:boton});
    }    
    });
app.listen(puerto, () => {console.log("Ejecutando express");});