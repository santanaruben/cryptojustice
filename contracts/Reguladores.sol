// SPDX-License-Identifier: MIT
pragma solidity >= 0.4.24 < 0.7.0;

import "./interfaces/ReguladoresI.sol";
import "./Pausable.sol";
import "./Roles.sol";

contract Reguladores is Pausable, ReguladoresI{

    using Roles for Roles.Role;
    Roles.Role internal reguladores;

    constructor() public {
        // crearRegulador(msg.sender);
    }

    modifier esRegulador() {
        require(comprobarRegulador(msg.sender),"Sin Rol");
        _;
    }

    function comprobarRegulador(address cuenta)
        public view
        returns(bool es)
    {
        es = reguladores.has(cuenta);
    }

    function crearRegulador(address cuenta)
        public
        fromOwner
        returns(bool exito)
    {
        require(!reguladores.has(cuenta), "Ya posee rol");
        reguladores.add(cuenta);
        emit LogReguladorCreado(cuenta);
        exito = true;
    }

    function eliminarRegulador(address cuenta)
        public
        fromOwner
        returns(bool exito)
    {
        require(reguladores.has(cuenta), "No posee rol");
        reguladores.remove(cuenta);
        emit LogReguladorEliminado(cuenta);
        exito = true;
    }
}