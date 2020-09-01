// SPDX-License-Identifier: MIT
pragma solidity >= 0.4.24 < 0.7.0;

import "./Reguladores.sol";
import "./interfaces/ReguladorI.sol";

contract Regulador is Reguladores, ReguladorI{

    using Roles for Roles.Role;
    Roles.Role internal jueces;
    Roles.Role internal camaras;
    Roles.Role internal cortes;
    Roles.Role internal peritos;

    struct Juez {
        uint indice;
    }
    address[] internal cuentasJueces;
    mapping(address => Juez) private mapeoJuez;

    struct EstructuraCategoria {
        bytes32 nombre;
        address[] peritos;
    }
    uint[] internal arregloCategorias;
    mapping(uint => EstructuraCategoria) internal mapeoCategorias;

    struct EstructuraPerito {
        uint idCategoria;
        uint indiceEstructuraCategoria;
    }
    mapping(address => EstructuraPerito) private mapeoPeritos;

    struct Camara {
        uint indice;
    }
    address[] internal cuentasCamaras;
    mapping(address => Camara) private mapeoCamara;

    struct CSJ {
        uint indice;
    }
    address[] internal cuentasCSJ;
    mapping(address => CSJ) private mapeoCSJ;

    constructor() public {
    }

    modifier esJuez() {
        require(comprobarJuez(msg.sender),"Sin Rol");
        _;
    }

    function comprobarJuez(address cuenta)
        public view
        returns(bool es)
    {
        es = jueces.has(cuenta);
    }

    function crearJuez(address cuenta)
        public
        esRegulador
        returns(bool exito)
    {
        require(!reguladores.has(cuenta) && !jueces.has(cuenta) && !camaras.has(cuenta) && !cortes.has(cuenta) && !peritos.has(cuenta), "Ya posee rol");
        jueces.add(cuenta);
        mapeoJuez[cuenta].indice = cuentasJueces.push(cuenta);
        emit LogJuezCreado(cuenta);
        exito = true;
    }

    function eliminarJuez(address cuenta)
        public
        esRegulador
        returns(bool exito)
    {
        require(jueces.has(cuenta), "No posee rol");
        jueces.remove(cuenta);
        uint indiceJuezCambiar = mapeoJuez[cuenta].indice;
        address cuentaUltimoJuez = cuentasJueces[cuentasJueces.length - 1];
        cuentasJueces.length--;
        cuentasJueces[indiceJuezCambiar] = cuentaUltimoJuez;
        mapeoJuez[cuentaUltimoJuez].indice = indiceJuezCambiar;
        emit LogJuezEliminado(cuenta);
        exito = true;
    }

    modifier esCamara() {
        require(comprobarCamara(msg.sender),"Sin Rol");
        _;
    }

    function comprobarCamara(address cuenta)
        public view
        returns(bool es)
    {
        es = camaras.has(cuenta);
    }

    function crearCamara(address cuenta)
        public
        esRegulador
        returns(bool exito)
    {
        require(!reguladores.has(cuenta) && !jueces.has(cuenta) && !camaras.has(cuenta) && !cortes.has(cuenta) && !peritos.has(cuenta), "Ya posee rol");
        camaras.add(cuenta);
        mapeoCamara[cuenta].indice = cuentasCamaras.push(cuenta);
        emit LogCamaraCreado(cuenta);
        exito = true;
    }

    function eliminarCamara(address cuenta)
        public
        esRegulador
        returns(bool exito)
    {
        require(camaras.has(cuenta), "No posee rol");
        camaras.remove(cuenta);
        uint indiceCamaraCambiar = mapeoCamara[cuenta].indice;
        address cuentaUltimoCamara = cuentasCamaras[cuentasCamaras.length - 1];
        cuentasCamaras.length--;
        cuentasCamaras[indiceCamaraCambiar] = cuentaUltimoCamara;
        mapeoCamara[cuentaUltimoCamara].indice = indiceCamaraCambiar;
        emit LogCamaraEliminado(cuenta);
        exito = true;
    }

    modifier esCorte() {
        require(comprobarCorte(msg.sender),"Sin Rol");
        _;
    }

    function comprobarCorte(address cuenta)
        public view
        returns(bool es)
    {
        es = cortes.has(cuenta);
    }

    function crearCorte(address cuenta)
        public
        esRegulador
        returns(bool exito)
    {
        require(!reguladores.has(cuenta) && !jueces.has(cuenta) && !camaras.has(cuenta) && !cortes.has(cuenta) && !peritos.has(cuenta), "Ya posee rol");
        cortes.add(cuenta);
        mapeoCSJ[cuenta].indice = cuentasCSJ.push(cuenta);
        emit LogCorteCreado(cuenta);
        exito = true;
    }

    function eliminarCorte(address cuenta)
        public
        esRegulador
        returns(bool exito)
    {
        require(cortes.has(cuenta), "No posee rol");
        cortes.remove(cuenta);
        uint indiceCSJCambiar = mapeoCSJ[cuenta].indice;
        address cuentaUltimoCSJ = cuentasCSJ[cuentasCSJ.length - 1];
        cuentasCSJ.length--;
        cuentasCSJ[indiceCSJCambiar] = cuentaUltimoCSJ;
        mapeoCSJ[cuentaUltimoCSJ].indice = indiceCSJCambiar;
        emit LogCorteEliminado(cuenta);
        exito = true;
    }

    function agregarCategoriaPerito(bytes32 nombreCategoriaPerito)
        public
        esRegulador
        returns (bool exito)
    {
        uint categoriaPerito = arregloCategorias.length;
        arregloCategorias.push(categoriaPerito);
        mapeoCategorias[categoriaPerito].nombre = nombreCategoriaPerito;
        emit LogCategoriaPeritoCreado(categoriaPerito, nombreCategoriaPerito, msg.sender);
        exito = true;
    }

    function editarCategoriaPerito(uint categoriaPerito, bytes32 nombreCategoriaPerito)
        public
        esRegulador
        returns (bool exito)
    {
        mapeoCategorias[categoriaPerito].nombre = nombreCategoriaPerito;
        emit LogCategoriaPeritoEditado(categoriaPerito, nombreCategoriaPerito, msg.sender);
        exito = true;
    }

    function verCategoriasPerito()
        public view
        returns (uint categorias)
    {
        categorias = arregloCategorias.length;
    }

    function verCategoriaPerito(uint idCategoria)
        public view
        returns (bytes32 nombre, address[] memory cuentas)
    {
        nombre = mapeoCategorias[idCategoria].nombre;
        cuentas = mapeoCategorias[idCategoria].peritos;
    }

    modifier esPerito() {
        require(comprobarPerito(msg.sender),"Sin Rol");
        _;
    }

    function comprobarPerito(address cuenta)
        public view
        returns(bool es)
    {
        es = peritos.has(cuenta);
    }

    function crearPerito(address cuenta, uint idCategoria)
        public
        esRegulador
        returns(bool exito)
    {
        require(!reguladores.has(cuenta) && !jueces.has(cuenta) && !camaras.has(cuenta) && !cortes.has(cuenta) && !peritos.has(cuenta), "Ya posee rol");
        require(idCategoria < arregloCategorias.length, 'Categoria no existe');
        peritos.add(cuenta);
        //Agrega la cuenta del perito a la estructura de la idCategoria indicada
        //y devuelve el indice para almacenarlo luego
        uint indiceEstructuraCategoria = mapeoCategorias[idCategoria].peritos.push(cuenta)-1;
        //Guarda el indice en el que fue almacenado el perito en la estructura categoría 
        mapeoPeritos[cuenta].indiceEstructuraCategoria = indiceEstructuraCategoria;
        emit LogPeritoCreado(cuenta, idCategoria);
        exito = true;
    }

    function eliminarPerito(address cuenta)
        public
        esRegulador
        returns(bool exito)
    {
        require(peritos.has(cuenta), "No posee rol");
        peritos.remove(cuenta);
        // EP: EstructuraPerito
        EstructuraPerito memory EP = mapeoPeritos[cuenta];
        uint idCategoria = EP.idCategoria;
        uint indiceRegistroEliminar = EP.indiceEstructuraCategoria;
        // ECP: EstructuraCategoriaPeritos
        address[] storage ECP = mapeoCategorias[idCategoria].peritos;
        address registroMover = ECP[ECP.length-1];
        ECP[indiceRegistroEliminar] = registroMover;
        mapeoPeritos[registroMover].indiceEstructuraCategoria = indiceRegistroEliminar; 
        ECP.length--;
        emit LogPeritoEliminado(cuenta);
        exito = true;
    }
}