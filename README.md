Propuesta de Desarrollo

 Intro
El proyecto describe un sistema para Procedimientos Judiciales en Ethereum.
Será representado por un contrato inteligente global:
* `CryptoJustice`

Poseerá además una cuenta administrativa con el fin de asignar roles que no pueden ser de perfil público o abierto:
* Regulador de `CryptoJustice`

Estos otros elementos del sistema son representados por cuentas externas:
* Demandante
* Demandado
* Juez
* Cámara de Apelaciones
* Corte Suprema de Justicia

 Regulador de `CryptoJustice`
Esta cuenta podrá:
* Asignar y gestionar roles para los siguientes participantes:
     * Juez
     * Cámara de Apelaciones
     * Corte Suprema de Justicia

 Demandante
Esta cuenta podrá:
* Establecer una demanda
* Evaluar propuesta del Demandado
* Transar con el Demandado
* No Transar con el Demandado
* Exponer alegatos
* Introducir recurso de apelación y de nulidad fundados ante sentencia
     * Introducción de Revocatoria y Apelación en Subsidio
     * Introducción de Revocatoria y Recurso Directo en Subsidio
* Introducción del Recurso de Aclaratoria y el Extraordinario en Subsidio
* Consentir Resolución de la Cámara
* No consentir Resolución de la Cámara
* Interponer Recurso Extraordinario ante la Cámara
* Emitir recurso de queja directo ante la CSJ para que estudie si la apertura del recurso fue bien o mal denegado

 Demandado
Esta cuenta podrá:
* Ser notificada
* Contestar aceptando la demanda
     * Pagar, aceptando los rubros sin discutir la liquidación
     * Pagar, aceptando los rubros pero discutiendo la liquidación
     * Pagar, aceptando parcialmente: cumple con lo consentido y con el resto litiga
* No contestar o rechazar la demanda
* Exponer alegatos
* Introducir recurso de apelación y de nulidad fundados ante sentencia
     * Introducción de Revocatoria y Apelación en Subsidio
     * Introducción de Revocatoria y Recurso Directo en Subsidio
* Introducción del Recurso de Aclaratoria y el Extraordinario en Subsidio
* Consentir Resolución de la Cámara
* No consentir Resolución de la Cámara
* Interponer Recurso Extraordinario ante la Cámara
* Emitir recurso de queja directo ante la CSJ para que estudie si la apertura del recurso fue bien o mal denegado

 Juez
Esta cuenta podrá:
* Homologar una sentencia
* Evaluar el mérito de la demanda y las pruebas ofrecidas
* Producir las pruebas en caso de no haber sido producidas por las partes
* La secretaría sortea Peritos, libra oficios y fija fecha para video conferencias
* Correr traslado simultáneo a las partes por 5 días para Alegar sobre el mérito de lo postulado por cada uno
* Fallar
* Notificar sentencia (Demandante y Demandado)
* Conceder vía recursiva decidiendo efecto y modo con los cuales se tramitarán
* Rechazar vía recursiva decidiendo efecto y modo con los cuales se tramitarán

 Cámara de Apelaciones
Esta cuenta podrá:
* Ordenar la producción de pruebas acotadas
* Fallar:
     * Admitir nulidad y retomar proceso
     * Admitir apelación y corregir el fallo
     * Rechazar uno o ambos recursos
* Aclarar la resolución (que Demandante y Demandado deben consentir)
* Rechazar recurso extraordinario
* Admitir recurso extraordinario

 Corte Suprema de Justicia
Esta cuenta podrá:
* Correr vista al Procurador General para que dictamine admisibilidad del recurso intentado por la Cámara
* Recibir todo lo actuado
* Ordenar medida para mejor proveer
* Fallar

 Opciones que tienen Demandante y Demandado
* Tener la posibilidad de producir las pruebas quedando así securizadas. Lo que sería de gran economía para el resto del proceso
* A pedido de partes, sortear peritos y fijar fechas para video conferencias de toma de testimonios
* Podrían ofrecer pruebas testimoniales ya producidas.. es decir ofrecer los videos de los testigos deponiendo bajo apercibimientos de falso testimonio..
* Ofrecer pruebas periciales ya producidas.. es decir INFORMES FIRMADOS POR PROFESIONALES que responderían por su MAL ARTE

 Notas importantes
* Toda prueba que se introduzca en este proceso tiene que ser bajo apercibimientos penales por obstrucción de la justicia y en carácter de declaraciones juradas para el caso de que se intente falsificar prueba
(la prueba -verdadera o falsificada- quedará securizada y podrá ser materia de denuncias penales contra los responsables)

 Contratos Inteligentes
Las bibliotecas `SafeMath` y `Roles` provistas por OpenZeppelin.
El contrato `CryptoJustice`.

 `CryptoJustice`
Este contrato posee las funciones principales del sistema. Las cosas que este puede hacer:
* Puede ser pausado / reanudado para detener las operaciones de `CryptoJustice`.
* Mantener registro de las demandas cargadas al sistema.

 Indicación de los contratos
Los contratos son encontrados en la carpeta `contracts`, aquí hay una lista de ellos:

* `Owned`, el cual gestiona y mantiene el registro de quien es el regulador de un contrato.
* `Pausable`, el cual mantiene registro del estatus _paused_ de un contrato.
* `CryptoJustice`, el cual describe los métodos requeridos por el sistema.

 `Owned`
tiene:
* un modificador llamado `fromOwner` que cancela la transacción si quien la envía no es el regulador.
* un constructor necesario, que no toma ningún parámetro.

 `Pausable`
tiene:
* un modificador llamado `whenPaused` que cancela la transacción si el contrato se encuentra en un estado de pausa `false`.
* un modificador llamado `whenNotPaused` que cancela la transacción si el contrato se encuentra en un estado de pausa `true`.
* un constructor que toma un parámetro de tipo `bool`, como estado de pausa inicial.

 Migraciones
Se usará el framework Truffle para la migración de los contratos.
Tendremos un script de migración `2_deploy_contracts.js` que podrá:
* desplegar un contrato `CryptoJustice` el cual podría ser pausado antes del paso de reanudación.

 Lenguajes
Solidity para la lógica de los contratos y el almacenamiento en la blockchain.
JavaScript como controlador principal de los procesos de la aplicación `CryptoJustice`.
(Estos son los lenguajes más robustos, flexibles y seguros en el espacio blockchain. Con la ventaja de ser amparados por la mayor comunidad de desarrolladores)
PHP y SQL para el almacenamiento de la data en bases de datos relacionales.
HTML y CSS para la interfaz gráfica.

 Controlador
Se usará la API `web3.js` como API de control para la comunicación entre la blockchain y la aplicación `CryptoJustice`.

 Interfaz de Usuario
Cualquier paquete NodeJS que usaremos, aparecerá en el archivo `package.json`.
Se planea trabajar con los frameworks:
* Bootstrap
* JQuery
* DataTables
* MomentJS
* Webpack
* React

Así que la interfaz tendrá:
* Una página de bienvenida, que permita:
     * Explicar los requerimientos básicos para interactuar con la aplicación.
* Una página de registro de usuario que esté disponible únicamente cuando los requerimientos básicos para interactuar hayan sido cubiertos, esta permitirá:
     * almacenar los datos vinculados con una cuenta Ethereum particular.
* Una página principal para el Regulador de `CryptoJustice`, que le permita:
     * Pausar / Reanudar las operaciones de `CryptoJustice`.
     * Ver las demandas cargadas al sistema.
     * Asignar Roles sobre determinadas cuentas.
* Una página principal para el participante de tipo Demandante / Demandado, que le permita:
     * Ver un historial con el estado y la descripción de las Demandas en las que está o ha estado involucrado.
     * Establecer una nueva Demanda.
     * Crear una nueva Actuación para una Demanda activa (o en proceso) particular.
     * En caso de tener que pagar o cobrar algún subsidio u honorario poder realizarlo directamente en la aplicación.
* Una página de Notificaciones disponible para todos los usuarios que les permita:
     * Mantener registro del cambio de estado con respecto a las Demandas en las que está o ha estado involucrado.
* Una página de tipo `Modal` que permita a los usuarios que interactúan con la aplicación (llenando formas o cargando pruebas):
     * Informarse con respecto a los delitos en que podrían incurrir en caso de falsificar información o pruebas que serán usados durante el proceso.
     * Declarar haber entendido las consecuencias de lo previamente informado y estar de acuerdo con los términos.
