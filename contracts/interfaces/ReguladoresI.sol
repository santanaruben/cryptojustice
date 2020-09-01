// SPDX-License-Identifier: MIT
pragma solidity >= 0.4.24 < 0.7.0;
contract ReguladoresI {
    event LogReguladorCreado(address indexed cuenta);
    event LogReguladorEliminado(address indexed cuenta);
    function comprobarRegulador(address cuenta) public view returns(bool es);
    function crearRegulador(address cuenta) public returns(bool exito);
    function eliminarRegulador(address cuenta) public returns(bool exito);
}