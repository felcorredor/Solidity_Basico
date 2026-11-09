// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ControlAsistencia {
    address profesor;
    uint idSesion;
    string temaClase;
    bool asistenciaActiva;
    bytes32 palabraSecreta;
    mapping(address => bool) asistio;
    address[] listaAsistentes;

    event AsistenciaAbierta(uint idSesion, string temaClase, uint fecha);
    event AsistenciaMarcada(address estudiante, uint idSesion, uint fecha);
    event AsistenciaCerrada(uint idSesion, uint fecha);

    modifier soloProfesor(){
        require(msg.sender == profesor, "Solo el profesor puede ejecutar esta funcion");
        _;
    }

   constructor() {
    profesor = msg.sender;
   }



    function abrirAsistencia(uint _idSesion, string memory _temaClase, string memory _palabraSecreta) public soloProfesor {
        idSesion = _idSesion;
        temaClase = _temaClase;
        asistenciaActiva = true;
        palabraSecreta = keccak256(abi.encodePacked(_palabraSecreta));
        emit AsistenciaAbierta(idSesion, temaClase, block.timestamp);
    }

    function marcarAsistencia(string memory _palabraIngresada) public  {
        require(asistenciaActiva,"La asistencia no esta activa!");
        require(!asistio[msg.sender],"ya marco aistencia!");
        require(
            keccak256(abi.encodePacked(_palabraIngresada)) == palabraSecreta, "Palabra secreta incorrecta"
            );
        asistio[msg.sender] = true;
        listaAsistentes.push(msg.sender);

        emit AsistenciaMarcada(msg.sender, idSesion, block.timestamp);
    }

    function cerrarAsistencia() public soloProfesor{
        asistenciaActiva = false;
        emit AsistenciaCerrada(idSesion, block.timestamp);
    }

    function totalAsistentes() public view returns (uint) {
        return listaAsistentes.length;
    }

     function obtenerAsistente(uint indice) public view returns (address) {
        require(indice < listaAsistentes.length, "Indice fuera de rango");
        return listaAsistentes[indice];
    }

        function consultarAsistencia(address estudiante) public view returns (bool) {
        return asistio[estudiante];
    }

    function consultarSesion() public view returns (uint, string memory, bool, uint) {
        return ( idSesion,temaClase,asistenciaActiva,listaAsistentes.length);
    }

    function obtenerListaAsistentes() public view returns (address[] memory) {
    return listaAsistentes;
    }

}
