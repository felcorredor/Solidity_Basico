// SPDX-License-Identifier: MIT

pragma solidity ^0.8.34;

/*
precioServ = $5000 COP -0.00057 ETH = 0.00057*10^18 = 000570000000000000 
hacer con if y luego array y revisar el conusmo de gas! - concluir.
-Poner modificadores de validacion de mes y año
¿Conviene fijar precios en ETH cuando el usuario piensa en COP, USD...?
*/

contract ServDiaNacimiento {

    uint public precioServ;
    address public propietario;

    event ConsultaRealizada(address usuario,uint anio,uint mes,uint dia,string diaEncontrado,uint valorPagado);

    constructor(uint _precioServ) {
        propietario = msg.sender;
        precioServ = _precioServ;
    }

    function consultarDiaNacimiento(uint anio,uint mes,uint dia) public payable returns (string memory) {

        require(msg.value >= precioServ, "No le alcanza, saque mas criptos!");
        //require(mes >= 1 && mes <= 12, "Mes invalido");
        //require(dia >= 1 && dia <= 31, "Dia invalido");

        string memory diaEncontrado = calcularDiaSemana(anio, mes, dia);

        emit ConsultaRealizada(msg.sender,anio,mes,dia,diaEncontrado,msg.value);

        return diaEncontrado;
    }

    function calcularDiaSemana(uint anio,uint mes,uint dia) internal pure returns (string memory) {

        uint[12] memory ajusteMes = [uint(0), 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4];

        if (mes < 3) {
            anio = anio - 1;
        }

        //algoritmo 
        uint numeroDia = ( anio + anio / 4 - anio / 100 + anio / 400 + ajusteMes[mes - 1] + dia ) % 7;
/*
        if (numeroDia == 0) return "Domingo";
        if (numeroDia == 1) return "Lunes";
        if (numeroDia == 2) return "Martes";
        if (numeroDia == 3) return "Miercoles";
        if (numeroDia == 4) return "Jueves";
        if (numeroDia == 5) return "Viernes";
        return "Sabado";
*/
        string[7] memory dsNacimiento = [string("Domingo"),"Lunes","Martes","Miercoles","Jueves","Viernes","Sabado"];
        return dsNacimiento[numeroDia];

    }

    function verSaldoContrato() public view returns (uint) {
        return address(this).balance;
    }

    function retirarFondos() public {
        require(msg.sender == propietario, "Solo el propietario puede retirar");

        uint saldo = address(this).balance;
        require(saldo > 0, "Contrato sin fondos!");

        (bool enviado, ) = payable(propietario).call{value: saldo}("");
        require(enviado, "No se pudo retirar el saldo");
    }
}