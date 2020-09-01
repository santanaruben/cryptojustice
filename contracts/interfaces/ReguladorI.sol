// SPDX-License-Identifier: MIT
pragma solidity >= 0.4.24 < 0.7.0;

contract ReguladorI {

    event LogJuezCreado(address indexed cuenta);
    event LogJuezEliminado(address indexed cuenta);
    event LogCamaraCreado(address indexed cuenta);
    event LogCamaraEliminado(address indexed cuenta);
    event LogCorteCreado(address indexed cuenta);
    event LogCorteEliminado(address indexed cuenta);
    event LogCategoriaPeritoCreado(uint indexed categoria, bytes32 nombre, address indexed cuenta);
    event LogCategoriaPeritoEditado(uint indexed categoria, bytes32 nombre, address indexed cuenta);
    event LogPeritoCreado(address indexed cuenta, uint indexed idCategoria);
    event LogPeritoEliminado(address indexed cuenta);

    function comprobarJuez(address cuenta) public view returns(bool es);

    function crearJuez(address cuenta) public returns(bool exito);

    function eliminarJuez(address cuenta) public returns(bool exito);

    function comprobarCamara(address cuenta) public view returns(bool es);

    function crearCamara(address cuenta) public returns(bool exito);

    function eliminarCamara(address cuenta) public returns(bool exito);

    function comprobarCorte(address cuenta) public view returns(bool es);

    function crearCorte(address cuenta) public returns(bool exito);

    function eliminarCorte(address cuenta) public returns(bool exito);

    function agregarCategoriaPerito(bytes32 nombreCategoriaPerito) public returns(bool exito);

    function editarCategoriaPerito(uint categoriaPerito, bytes32 nombreCategoriaPerito) public returns(bool exito);

    function verCategoriasPerito() public view returns (uint categorias);

    function verCategoriaPerito(uint idCategoria) public view returns (bytes32 nombre, address[] memory cuentas);

    function comprobarPerito(address cuenta) public view returns(bool es);

    function crearPerito(address cuenta, uint idCategoria) public returns(bool exito);

    function eliminarPerito(address cuenta) public returns(bool exito);
}