// SPDX-License-Identifier: MIT
pragma solidity >= 0.4.24 < 0.7.0;

import "./Actor.sol";

contract Litigio is Actor {

    event LogDemandaCreada(uint idDemanda, address cuentaActor, bytes32 idActor, bytes32 idDemandado, bytes32 actuacion);
    event LogDemandaContestada(uint idDemanda, address cuentaDemandado, address juez, EstadoDemanda nuevoEstado, bytes32 actuacion);
    event LogLiquidacionAceptada(uint idDemanda, address aceptadaPor, bytes32 actuacion);
    event LogLiquidacionRechazada(uint idDemanda, address rechazadaPor, bytes32 actuacion);
    event LogDemandaHomologada(uint idDemanda, address juez, bytes32 actuacion);
    event LogDemandaFalladaJuez(uint idDemanda, address juez, bytes32 actuacion);
    event LogDemandaEnPericia(uint idDemanda, address juez, address[] cuentasPeritos, bytes32 actuacion);
    event LogDemandaPericiada(uint idDemanda, address perito, bytes32 actuacion);
    event LogRecursoApelacionYNulidad(uint idDemanda, address cuenta);
    event LogRecursoAYNRecibido(uint idDemanda, bool aceptado);
    event LogRecursoRevocatoriaYDirectoEnSubsidio(uint idDemanda, address cuenta);
    event LogRecursoRevocatoriaYApelacionEnSubsidio(uint idDemanda, address cuenta);
    event LogDemandaFalladaCamara(uint idDemanda, address camara, bytes32 actuacion);
    event LogRecursoAclaratoriaYExtraordinarioEnSubsidio(uint idDemanda, address cuenta);
    event LogResolucionAclarada(uint idDemanda, address camara, bytes32 actuacion);
    event LogResolucionConsentida(uint idDemanda, address cuenta);
    event LogResolucionNoConsentida(uint idDemanda, address cuenta);
    event LogRecursoExtraordinarioAnteCamara(uint idDemanda, address cuenta);
    event LogRecursoEACRecibido(uint idDemanda, bool aceptado);
    event LogRecursoQuejaDirectoAnteCSJ(uint idDemanda, address cuenta);
    event LogRecursoQDACSJRecibido(uint idDemanda, bool aceptado);
    event LogDemandaFalladaCSJ(uint idDemanda, address camara, bytes32 actuacion);

    constructor() public {
    }

    enum EstadoDemanda {
        noExisteDemanda,                                //0
        esperaContestacion,                             //1
        rechazada,                                      //2
        aceptadaParcialmente,                           //3
        aceptadaDiscutiendo,                            //4
        esperaHomologacion,                             //5
        enPericias,                                     //6
        enSentenciaJuez,                                //7
        falloDeJuez,                                    //8
        recursoApelacionYNulidad,                       //9
        recursoAYNRechazado,                            //10
        recursoAYNAceptado,                             //11
        recursoRevocatoriaYDirectoEnSubsidio,           //12
        recursoRevocatoriaYApelacionEnSubsidio,         //13
        enSentenciaCamara,                              //14
        falloDeCamara,                                  //15
        recursoAclaratoriaYExtraordinarioEnSubsidio,    //16
        resolucionAclarada,                             //17
        resolucionNoConsentida,                         //18
        recursoExtraordinarioAnteCamara,                //19
        recursoEACRechazado,                            //20
        recursoQuejaDirectoAnteCSJ,                     //21
        enSentenciaCSJ,                                 //22
        finDemanda                                      //23
    }

    struct Demanda {
        EstadoDemanda estadoDemanda;
        bytes32 idActor;
        bytes32 idDemandado;
        address cuentaJuez;
        address cuentaCamara;
        address cuentaCSJ;
        address[] cuentasPeritos;
        address[] yaHizoPericia;
        address[] yaConsintio;
        bytes32[] actuacionesDemanda;
        bytes32 liquidacionPropuestaPor;
        
    }
    // clave: ID de la demanda
    mapping(uint => Demanda) private mapeoDemandas;
    address[] private arregloDemandas;

    struct ActorDemandas {
        uint[] idDemandas;
    }
    // clave: Cuenta del Actor
    mapping(address => ActorDemandas) private mapeoActorDemandas;

    struct DemandadoDemandas {
        uint[] idDemandas;
    }
    // clave: ID del Demandado
    mapping(bytes32 => DemandadoDemandas) private mapeoDemandadoDemandas;

    struct JuezDemandas {
        uint[] idDemandas;
    }
    // clave: Cuenta del Juez
    mapping(address => JuezDemandas) private mapeoJuezDemandas;

    struct PeritoDemandas {
        uint[] idDemandas;
    }
    // clave: Cuenta del Perito
    mapping(address => PeritoDemandas) private mapeoPeritoDemandas;

    struct CamaraDemandas {
        uint[] idDemandas;
    }
    // clave: Cuenta de la Cámara de Apelaciones
    mapping(address => CamaraDemandas) private mapeoCamaraDemandas;

    struct CSJDemandas {
        uint[] idDemandas;
    }
    // clave: Cuenta de la Corte Suprema de Justicia
    mapping(address => CSJDemandas) private mapeoCSJDemandas;

    function crearDemanda(
        bytes32 idDemandado,
        bytes32 actuacion)
    public
    returns(uint idDemanda) {
        require(comprobarUsuario(msg.sender),'No es usuario');
        bytes32 idActor = mapeoEstructuraUsuario[msg.sender].id;
        require(idActor != idDemandado,'No puede autodemandarse');
        idDemanda = arregloDemandas.length;
        arregloDemandas.push(msg.sender);
        mapeoActorDemandas[msg.sender].idDemandas.push(idDemanda);
        mapeoDemandadoDemandas[idDemandado].idDemandas.push(idDemanda);
        Demanda storage d = mapeoDemandas[idDemanda];
        d.idActor = idActor;
        d.idDemandado = idDemandado;
        d.actuacionesDemanda.push(actuacion);
        d.estadoDemanda = EstadoDemanda.esperaContestacion;
        d.liquidacionPropuestaPor = idDemandado;
        emit LogDemandaCreada(idDemanda, msg.sender, idActor, idDemandado, actuacion);
        return idDemanda;
    }

    function verDemanda(uint idDemanda)
    public view
    returns(EstadoDemanda,
            bytes32,
            bytes32,
            address,
            address,
            address,
            address[] memory,
            address[] memory,
            address[] memory,
            bytes32[] memory,
            bytes32)
    {
        Demanda storage d = mapeoDemandas[idDemanda];
        return( d.estadoDemanda,
                d.idActor,
                d.idDemandado,
                d.cuentaJuez,
                d.cuentaCamara,
                d.cuentaCSJ,
                d.cuentasPeritos,
                d.yaHizoPericia,
                d.yaConsintio,
                d.actuacionesDemanda,
                d.liquidacionPropuestaPor);
    }

    function verDemandasActor(address cuentaActor)
    public view
    returns(uint[] memory)
    {
        return mapeoActorDemandas[cuentaActor].idDemandas;
    }

    function verDemandasDemandado(bytes32 idDemandado)
    public view
    returns(uint[] memory)
    {
        return mapeoDemandadoDemandas[idDemandado].idDemandas;
    }

    function verDemandasJuez(address cuentaJuez)
    public view
    returns(uint[] memory)
    {
        return mapeoJuezDemandas[cuentaJuez].idDemandas;
    }

    function verDemandasPerito(address cuentaPerito)
    public view
    returns(uint[] memory)
    {
        return mapeoPeritoDemandas[cuentaPerito].idDemandas;
    }

    function verDemandasCamara(address cuentaCamara)
    public view
    returns(uint[] memory)
    {
        return mapeoCamaraDemandas[cuentaCamara].idDemandas;
    }

    function verDemandasCSJ(address cuentaCSJ)
    public view
    returns(uint[] memory)
    {
        return mapeoCSJDemandas[cuentaCSJ].idDemandas;
    }

    function contestarDemanda(uint idDemanda, EstadoDemanda nuevoEstado, bytes32 actuacion)
    public
    returns(bool exito)
    {
        Demanda storage d = mapeoDemandas[idDemanda];
        (address cuentaDemandado,) = verUsuarioExistencia(d.idDemandado);
        require(msg.sender == cuentaDemandado, 'Usted no es el demandado');
        require(d.estadoDemanda == EstadoDemanda.esperaContestacion, 'No es momento');
        d.estadoDemanda = nuevoEstado;
        d.actuacionesDemanda.push(actuacion);
        address juez;
        juez = Regulador.cuentasJueces[now % Regulador.cuentasJueces.length];
        d.cuentaJuez = juez;
        mapeoJuezDemandas[juez].idDemandas.push(idDemanda);
        emit LogDemandaContestada(idDemanda, msg.sender, juez, nuevoEstado, actuacion);
        exito = true;
    }

    function proponerLiquidacion(uint idDemanda)
    public
    returns(bool exito)
    {
        Demanda storage d = mapeoDemandas[idDemanda];
        (bytes32 idUsuario,,) = verUsuario(msg.sender);
        require(idUsuario != d.liquidacionPropuestaPor, 'No es su turno');
        require(d.estadoDemanda == EstadoDemanda.aceptadaDiscutiendo, 'No es momento');
        if(idUsuario == d.idActor) {
            d.liquidacionPropuestaPor = d.idActor;
            exito = true;
        }
        else if(idUsuario == d.idDemandado) {
            d.liquidacionPropuestaPor = d.idDemandado;
            exito = true;
        }
        else exito = false;
    }

    function esUsuarioDemanda(bytes32 idActor, bytes32 idDemandado)
    public view
    returns(bool es) 
    {
        (address cuentaActor,) = verUsuarioExistencia(idActor);
        (address cuentaDemandado,) = verUsuarioExistencia(idDemandado);
        if (msg.sender == cuentaDemandado || msg.sender == cuentaActor)
            return true;
        else return false;
    }

    function aceptarLiquidacion(uint idDemanda, bytes32 actuacion)
    public
    returns(bool exito)
    {
        Demanda storage d = mapeoDemandas[idDemanda];
        require(esUsuarioDemanda(d.idActor, d.idDemandado));
        (bytes32 idUsuario,,) = verUsuario(msg.sender);
        require(idUsuario != d.liquidacionPropuestaPor, 'Usted propuso, no puede aceptar');
        require(d.estadoDemanda == EstadoDemanda.aceptadaDiscutiendo, 'No es momento');
        d.estadoDemanda = EstadoDemanda.esperaHomologacion;
        d.actuacionesDemanda.push(actuacion);
        emit LogLiquidacionAceptada(idDemanda, msg.sender, actuacion);
        exito = true;
    }

    function rechazarLiquidacion(uint idDemanda, bytes32 actuacion)
    public
    returns(bool exito)
    {
        Demanda storage d = mapeoDemandas[idDemanda];
        require(esUsuarioDemanda(d.idActor, d.idDemandado));
        require(d.estadoDemanda == EstadoDemanda.aceptadaDiscutiendo, 'No es momento');
        d.estadoDemanda = EstadoDemanda.aceptadaParcialmente;
        d.actuacionesDemanda.push(actuacion);
        emit LogLiquidacionRechazada(idDemanda, msg.sender, actuacion);
        exito = true;
    }

    function homologar(uint idDemanda, bytes32 actuacion)
    public
    returns(bool exito)
    {
        Demanda storage d = mapeoDemandas[idDemanda];
        require(msg.sender == d.cuentaJuez, 'Usted no es el Juez');
        require(d.estadoDemanda == EstadoDemanda.esperaHomologacion, 'No es momento');
        d.estadoDemanda = EstadoDemanda.finDemanda;
        d.actuacionesDemanda.push(actuacion);
        emit LogDemandaHomologada(idDemanda, msg.sender, actuacion);
        exito = true;
    }

    function solicitarPericias(uint idDemanda, uint[] memory tipoPeritos, bytes32 actuacion)
    public
    returns(bool exito)
    {
        Demanda storage d = mapeoDemandas[idDemanda];
        require(msg.sender == d.cuentaJuez, 'Usted no es el Juez');
        require(d.estadoDemanda == EstadoDemanda.rechazada || d.estadoDemanda == EstadoDemanda.aceptadaParcialmente, 'No es momento');
        d.estadoDemanda = EstadoDemanda.enPericias;
        d.actuacionesDemanda.push(actuacion);
        uint i;
        address perito;
        address[] memory peritos;
        for(i = 0; i < tipoPeritos.length; i++)
        {
            peritos = Regulador.mapeoCategorias[tipoPeritos[i]].peritos;
            perito = peritos[now % peritos.length];
            d.cuentasPeritos.push(perito);
            mapeoPeritoDemandas[perito].idDemandas.push(idDemanda);
        }
        emit LogDemandaEnPericia(idDemanda, msg.sender, d.cuentasPeritos, actuacion);
        exito = true;
    }

    function fallarJuez(uint idDemanda, bytes32 actuacion)
    public
    returns(bool exito)
    {
        Demanda storage d = mapeoDemandas[idDemanda];
        require(msg.sender == d.cuentaJuez, 'Usted no es el Juez');
        require(d.estadoDemanda == EstadoDemanda.rechazada || d.estadoDemanda == EstadoDemanda.aceptadaParcialmente || d.estadoDemanda == EstadoDemanda.enSentenciaJuez, 'No es momento');
        d.estadoDemanda = EstadoDemanda.falloDeJuez;
        d.actuacionesDemanda.push(actuacion);
        emit LogDemandaFalladaJuez(idDemanda, msg.sender, actuacion);
        exito = true;
    }

    function pericia(uint idDemanda, bytes32 actuacion)
    public
    returns(bool exito)
    {
        Demanda storage d = mapeoDemandas[idDemanda];
        require(estaContenidoEn(d.cuentasPeritos), 'No es Perito de esta demanda');
        require(d.estadoDemanda == EstadoDemanda.enPericias, 'No es momento');
        require(!estaContenidoEn(d.yaHizoPericia), 'Ya perició esta demanda');
        d.yaHizoPericia.push(msg.sender);
        d.actuacionesDemanda.push(actuacion);
        if(d.yaHizoPericia.length == d.cuentasPeritos.length)
            d.estadoDemanda = EstadoDemanda.enSentenciaJuez;
        emit LogDemandaPericiada(idDemanda, msg.sender, actuacion);
        exito = true;
    }

    function estaContenidoEn(address[] memory cuentas)
    public view
    returns(bool)
    {
        uint i = 0;
        while(i < cuentas.length) {
            if(cuentas[i] == msg.sender) return true;
            i++;
        }
        return false;
    }

    function recursoApelacionYNulidad(uint idDemanda)
    public
    returns(bool exito)
    {
        Demanda storage d = mapeoDemandas[idDemanda];
        require(esUsuarioDemanda(d.idActor, d.idDemandado));
        require(d.estadoDemanda == EstadoDemanda.falloDeJuez, 'No es momento');
        d.estadoDemanda = EstadoDemanda.recursoApelacionYNulidad;
        emit LogRecursoApelacionYNulidad(idDemanda, msg.sender);
        exito = true;
    }

    function recursoAYNRecibido(uint idDemanda, bool aceptado)
    public
    returns(bool exito)
    {
        Demanda storage d = mapeoDemandas[idDemanda];
        require(msg.sender == d.cuentaJuez, 'Usted no es el Juez');
        require(d.estadoDemanda == EstadoDemanda.recursoApelacionYNulidad, 'No es momento');
        if(aceptado)
            d.estadoDemanda = EstadoDemanda.recursoAYNAceptado;
        else
            d.estadoDemanda = EstadoDemanda.recursoAYNRechazado;
        emit LogRecursoAYNRecibido(idDemanda, aceptado);
        exito = true;
    }

    function recursoRevocatoriaYDirectoEnSubsidio(uint idDemanda)
    public
    returns(bool exito)
    {
        Demanda storage d = mapeoDemandas[idDemanda];
        require(esUsuarioDemanda(d.idActor, d.idDemandado));
        require(d.estadoDemanda == EstadoDemanda.recursoAYNRechazado, 'No es momento');
        address camara;
        camara = Regulador.cuentasCamaras[now % Regulador.cuentasCamaras.length];
        d.cuentaCamara = camara;
        mapeoCamaraDemandas[camara].idDemandas.push(idDemanda);
        d.estadoDemanda = EstadoDemanda.enSentenciaCamara;
        emit LogRecursoRevocatoriaYDirectoEnSubsidio(idDemanda, msg.sender);
        exito = true;
    }

    function recursoRevocatoriaYApelacionEnSubsidio(uint idDemanda)
    public
    returns(bool exito)
    {
        Demanda storage d = mapeoDemandas[idDemanda];
        require(esUsuarioDemanda(d.idActor, d.idDemandado));
        require(d.estadoDemanda == EstadoDemanda.recursoAYNAceptado, 'No es momento');
        address camara;
        camara = Regulador.cuentasCamaras[now % Regulador.cuentasCamaras.length];
        d.cuentaCamara = camara;
        mapeoCamaraDemandas[camara].idDemandas.push(idDemanda);
        d.estadoDemanda = EstadoDemanda.enSentenciaCamara;
        emit LogRecursoRevocatoriaYApelacionEnSubsidio(idDemanda, msg.sender);
        exito = true;
    }

    function fallarCamara(uint idDemanda, bytes32 actuacion)
    public
    returns(bool exito)
    {
        Demanda storage d = mapeoDemandas[idDemanda];
        require(msg.sender == d.cuentaCamara, 'Usted no es la Cámara de Apelaciones');
        require(d.estadoDemanda == EstadoDemanda.enSentenciaCamara, 'No es momento');
        d.estadoDemanda = EstadoDemanda.falloDeCamara;
        d.actuacionesDemanda.push(actuacion);
        emit LogDemandaFalladaCamara(idDemanda, msg.sender, actuacion);
        exito = true;
    }

    function recursoAclaratoriaYExtraordinarioEnSubsidio(uint idDemanda)
    public
    returns(bool exito)
    {
        Demanda storage d = mapeoDemandas[idDemanda];
        require(esUsuarioDemanda(d.idActor, d.idDemandado));
        require(d.estadoDemanda == EstadoDemanda.falloDeCamara, 'No es momento');
        d.estadoDemanda = EstadoDemanda.recursoAclaratoriaYExtraordinarioEnSubsidio;
        emit LogRecursoAclaratoriaYExtraordinarioEnSubsidio(idDemanda, msg.sender);
        exito = true;
    }

    function aclararResolucion(uint idDemanda, bytes32 actuacion)
    public
    returns(bool exito)
    {
        Demanda storage d = mapeoDemandas[idDemanda];
        require(msg.sender == d.cuentaCamara, 'Usted no es la Cámara de Apelaciones');
        require(d.estadoDemanda == EstadoDemanda.recursoAclaratoriaYExtraordinarioEnSubsidio, 'No es momento');
        d.estadoDemanda = EstadoDemanda.resolucionAclarada;
        d.actuacionesDemanda.push(actuacion);
        emit LogResolucionAclarada(idDemanda, msg.sender, actuacion);
        exito = true;
    }

    function consentirResolucion(uint idDemanda, bool consentimiento)
    public
    returns(bool exito)
    {
        Demanda storage d = mapeoDemandas[idDemanda];
        require(esUsuarioDemanda(d.idActor, d.idDemandado));
        require(!estaContenidoEn(d.yaConsintio), 'Ya consintió la aclaratoria');
        require(d.estadoDemanda == EstadoDemanda.resolucionAclarada, 'No es momento');
        if(consentimiento) {
            d.yaConsintio.push(msg.sender);
            if(d.yaConsintio.length == 2)
                d.estadoDemanda = EstadoDemanda.finDemanda;
            emit LogResolucionConsentida(idDemanda, msg.sender);
        }
        else {
            d.estadoDemanda = EstadoDemanda.resolucionNoConsentida;
            emit LogResolucionNoConsentida(idDemanda, msg.sender);
        }
        exito = true;
    }
    
    function recursoExtraordinarioAnteCamara(uint idDemanda)
    public
    returns(bool exito)
    {
        Demanda storage d = mapeoDemandas[idDemanda];
        require(esUsuarioDemanda(d.idActor, d.idDemandado));
        require(d.estadoDemanda == EstadoDemanda.resolucionNoConsentida, 'No es momento');
        address csj;
        csj = Regulador.cuentasCSJ[now % Regulador.cuentasCSJ.length];
        d.cuentaCSJ = csj;
        mapeoCSJDemandas[csj].idDemandas.push(idDemanda);
        d.estadoDemanda = EstadoDemanda.recursoExtraordinarioAnteCamara;
        emit LogRecursoExtraordinarioAnteCamara(idDemanda, msg.sender);
        exito = true;
    }

    function recursoEACRecibido(uint idDemanda, bool aceptado)
    public
    returns(bool exito)
    {
        Demanda storage d = mapeoDemandas[idDemanda];
        require(msg.sender == d.cuentaCamara, 'Usted no es la Cámara de Apelaciones');
        require(d.estadoDemanda == EstadoDemanda.recursoExtraordinarioAnteCamara, 'No es momento');
        if(aceptado)
            d.estadoDemanda = EstadoDemanda.enSentenciaCSJ;
        else
            d.estadoDemanda = EstadoDemanda.recursoEACRechazado;
        emit LogRecursoEACRecibido(idDemanda, aceptado);
        exito = true;
    }

    function recursoQuejaDirectoAnteCSJ(uint idDemanda)
    public
    returns(bool exito)
    {
        Demanda storage d = mapeoDemandas[idDemanda];
        require(esUsuarioDemanda(d.idActor, d.idDemandado));
        require(d.estadoDemanda == EstadoDemanda.recursoEACRechazado, 'No es momento');
        d.estadoDemanda = EstadoDemanda.recursoQuejaDirectoAnteCSJ;
        emit LogRecursoQuejaDirectoAnteCSJ(idDemanda, msg.sender);
        exito = true;
    }

    function recursoQDACSJRecibido(uint idDemanda, bool aceptado)
    public
    returns(bool exito)
    {
        Demanda storage d = mapeoDemandas[idDemanda];
        require(msg.sender == d.cuentaCSJ, 'Usted no es la Corte Suprema de Justicia');
        require(d.estadoDemanda == EstadoDemanda.recursoQuejaDirectoAnteCSJ, 'No es momento');
        if(aceptado)
            d.estadoDemanda = EstadoDemanda.enSentenciaCSJ;
        else
            d.estadoDemanda = EstadoDemanda.finDemanda;
        emit LogRecursoQDACSJRecibido(idDemanda, aceptado);
        exito = true;
    }

    function fallarCSJ(uint idDemanda, bytes32 actuacion)
    public
    returns(bool exito)
    {
        Demanda storage d = mapeoDemandas[idDemanda];
        require(msg.sender == d.cuentaCSJ, 'Usted no es la Corte Suprema de Justicia');
        require(d.estadoDemanda == EstadoDemanda.enSentenciaCSJ, 'No es momento');
        d.estadoDemanda = EstadoDemanda.finDemanda;
        d.actuacionesDemanda.push(actuacion);
        emit LogDemandaFalladaCSJ(idDemanda, msg.sender, actuacion);
        exito = true;
    }

}