// SPDX-License-Identifier: MIT
pragma solidity >= 0.4.24 < 0.7.0;

import "./Regulador.sol";

contract Actor is Regulador {

    event LogUsuarioRegistrado(address indexed cuenta, bytes32 indexed id);
    event LogUsuarioInactivado(address indexed cuenta);
    event LogUsuarioReactivado(address indexed cuenta);

    constructor() public {
    }

    struct Usuario {
        bytes32 id;
        bool activo;
        uint indice;
    }

    struct UsuarioCuenta {
        address cuenta;
        bool existe;
    }

    // Mapeo usado con la cuenta para almacenamiento de usuarios
    mapping(address => Usuario) internal mapeoEstructuraUsuario;
    // Mapeo usado con el id del usuario para control del Regulador
    mapping(bytes32 => UsuarioCuenta) private mapeoEstructuraUsuarioExistencia;
    
    address[] private arregloDeCuentas;

    function comprobarUsuario(address cuenta)
    public view
    returns(bool es) {
        if (arregloDeCuentas.length == 0) return false;
        return (arregloDeCuentas[mapeoEstructuraUsuario[cuenta].indice] == cuenta);
    }

    function crearUsuario(
        address cuenta,
        bytes32 id)
    public
    returns(bool exito) {
        require(!comprobarUsuario(cuenta),'Es usuario');
        (, bool existeU) = verUsuarioExistencia(id);
        require(!existeU, 'ID asignado a otra cuenta');
        require(!isOwner() && !reguladores.has(cuenta) && !jueces.has(cuenta) && !camaras.has(cuenta) && !cortes.has(cuenta), "Ya posee rol");
        UsuarioCuenta storage uc = mapeoEstructuraUsuarioExistencia[id];
        uc.cuenta = cuenta;
        uc.existe = true;
        Usuario storage u = mapeoEstructuraUsuario[cuenta];
        u.id = id;
        u.activo = true;
        u.indice = arregloDeCuentas.push(cuenta) - 1;
        emit LogUsuarioRegistrado(cuenta, id);
        exito = true;
    }

    function verUsuario(address cuenta)
    public view
    returns(bytes32 id, bool activo, uint indice) {
        require(comprobarUsuario(cuenta),'No es usuario');
        Usuario storage u = mapeoEstructuraUsuario[cuenta];
        return (u.id, u.activo, u.indice);
    }

    function verUsuarioExistencia(bytes32 id)
    public view
    returns(address cuenta, bool existe) {
        UsuarioCuenta storage uc = mapeoEstructuraUsuarioExistencia[id];
        return (uc.cuenta, uc.existe);
    }

    function inactivarUsuario(address cuenta)
    public
    esRegulador
    returns(bool exito) {
        require(comprobarUsuario(cuenta),'No es usuario');
        mapeoEstructuraUsuario[cuenta].activo = false;
        emit LogUsuarioInactivado(cuenta);
        exito = true;
    }

    function reactivarUsuario(address cuenta)
    public
    esRegulador
    returns(bool exito) {
        require(comprobarUsuario(cuenta),'No es usuario');
        mapeoEstructuraUsuario[cuenta].activo = true;
        emit LogUsuarioReactivado(cuenta);
        exito = true;
    }

}