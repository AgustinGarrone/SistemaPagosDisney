// SPDX-License-Identifier: MIT
pragma solidity 0.7.0;
pragma experimental ABIEncoderV2;
import "./ERC20.sol";

contract disney {

    ERC20Basic private token;

    //disney address
    address payable public owner;

    constructor () public {
        token=new ERC20Basic(10000);
        owner= msg.sender;

    }

    struct cliente {
        uint tokensComprados;
        string [] atracciones_pagas;
    }

    mapping (address=>cliente) public Clientes;

    function precioTokens(uint _cantidad) internal pure returns (uint) {
        return _cantidad*(1 ether);
    }

    function comprarTokens(uint _cantidad) public payable {
        uint costo=precioTokens(_cantidad) ;
        //evaluamos el dinero que el cliente paga por los tokens
        require(msg.value>=costo,"No te alcanza.");
        uint vuelto=msg.value-costo;
        msg.sender.transfer(vuelto);
        uint Balance=balanceOf();
        require(_cantidad<=Balance,"compra un numero menor de tokens,no hay esa cantidad");
        //transferimos el num de tokens al cliente
        token.transfer(msg.sender,_cantidad);
        Clientes[msg.sender].tokensComprados+=_cantidad;
    }

    function balanceOf() public view returns (uint) {
        return token.balanceOf(address(this));
    }

    function misTokens() public view returns (uint) {
        return token.balanceOf(msg.sender);
    }

    modifier unicamente(address _dir) {
        require(_dir==owner,"no tienes permisos");
        _;
    }

    function generaTokens (uint _numTokens) public unicamente(msg.sender) {
        token.increaseTotalSupply(_numTokens);
    }

    //EVENTOS

    event disfruta_atraccion(string);
    event nueva_atraccion(string,uint);
    event baja_atraccion(string);

    struct atraccion {
        string nombre_atraccion;
        uint precio_atraccion;
        bool estado_atraccion;
    }
    mapping (string=>atraccion) public mappingAtracciones;

    string [] Atracciones;
   /*  string  [] public disponibles; */
    mapping (address=>string[]) historialAtracciones;


    function crearAtraccion(string memory _nombre,uint _precio) public unicamente(msg.sender) {
        mappingAtracciones[_nombre]=atraccion(_nombre,_precio,true);
        Atracciones.push(_nombre);
        emit nueva_atraccion(_nombre,_precio);
    }

    function eliminarAtraccion (string memory _nombre) public unicamente(msg.sender) {  
        bool flag=false;
        for (uint i=0;i<Atracciones.length;i++) {
            if (keccak256(abi.encodePacked(_nombre))==keccak256(abi.encodePacked(Atracciones[i]))) {
                flag=true;
            }
        }
        require(flag==true,"No se encontro la atraccion a eliminar");
        mappingAtracciones[_nombre].estado_atraccion=false;
        for (uint i=0;i<Atracciones.length;i++) {

        }
        emit baja_atraccion(_nombre);
    }

    function atraccionesDisponibles() public view returns (string [] memory){
        return Atracciones;
    }


    function pagarAtraccion(string memory _nombre) public {
        uint costoAtraccion=mappingAtracciones[_nombre].precio_atraccion;
        require(mappingAtracciones[_nombre].estado_atraccion==true,"Atraccion en mantenimiento");
        require(misTokens()>=costoAtraccion,"Necesitas mas tokens para subirte a la atraccion");
        token.transferenciaDisney(msg.sender,address(this),costoAtraccion);
        historialAtracciones[msg.sender].push(_nombre);
        emit disfruta_atraccion(_nombre);
    }

    function historialCliente () public view returns (string [] memory) {
        return historialAtracciones[msg.sender];
    }

    //Hacemos PAYABLE porque interactuamos con ETHERS al devolver nuestros tokens.
    function devolverTokens () public payable{
        uint tokensSobrantes=misTokens();
        require(tokensSobrantes>0,"No tienes tokens que devolver");
        token.transferenciaDisney(msg.sender,address(this),tokensSobrantes);
        //Devolucion de ethers al cliente
        msg.sender.transfer(precioTokens(tokensSobrantes));
    }

}