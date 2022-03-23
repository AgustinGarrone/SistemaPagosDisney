pragma solidity 0.7.0;
pragma experimental ABIEncoderV2;
import "./SafeMath.sol";

//OWNER 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
//JUAN 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
//MARIa 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db


interface IERC20 {
    
    //devuelve el supply total 
    function totalSupply() external view returns (uint);
    
    //devuelve el balance de tokens en una direccion indicada por parametro
    function balanceOf(address account) external view returns (uint);
    
    //devuelve el numero de tokens que el spender podrá gastar en nombre del owner
    function allowance(address owner, address spender) external view returns (uint);

    //devuelve el valor booleano de la operacion indicada
    function transfer (address recipient, uint amount) external returns (bool);

    function transferenciaDisney (address _cliente,address recipient, uint amount) external returns (bool);

    //devuelve un valor booleano con el resultado de la operacion de delegación de tokens
    function approve (address spender, uint amount) external returns (bool);

    //devuelve valor booleano con la operación de paso de una cantidad de tokens usando el metodo allowance
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);

    //evento que se debe emitir cuando tokens pasan de un origen a un destino
    event Transfer (address indexed from,address indexed to,uint value);

    //evento que se debe emitir cuando se establece asignacion con el metodo de allowance()
    event Approval (address indexed owner, address indexed spender , uint value);

    //https://solidity-by-example.org/app/erc20/
}

contract ERC20Basic is IERC20 {

    address public contractOwner;

    string public constant name= "DisneyCoin";
    string public constant symbol="DSN";
    uint8 public constant decimals=2;


    mapping (address=>uint) balances;
    mapping (address => mapping (address=>uint)) allowed;
    uint totalSupply_;

    constructor (uint initialSupply) public {
        contractOwner=msg.sender;
        totalSupply_=initialSupply;
        balances[msg.sender]=totalSupply_;
    }

    using SafeMath for uint;
    

    function totalSupply() public override view returns (uint) {
        return totalSupply_;
    }
    //INCREMENTA EL SUPPLY TOTAL A TRAVES DE MINADO (?
    function increaseTotalSupply(uint newAmount) public {
        require(msg.sender==contractOwner,"no tienes permisos");
        totalSupply_+=newAmount;
        balances[msg.sender]+=newAmount;
    }

    function balanceOf(address tokenOwner) public override view returns (uint) {
        return balances[tokenOwner];
    }

    function allowance(address owner, address spender) public override view returns (uint) {
        return allowed[owner][spender];
    }

    function transfer (address recipient, uint amount) public override returns (bool) {
        require(amount<=balances[msg.sender]);
        balances[msg.sender]=balances[msg.sender].sub(amount);
        balances[recipient]=balances[recipient].add(amount);
        emit Transfer(msg.sender,recipient,amount);
        return true;
    }
    function transferenciaDisney (address _cliente, address recipient, uint amount) public override returns (bool) {
        require(amount<=balances[_cliente]);
        balances[_cliente]=balances[_cliente].sub(amount);
        balances[recipient]=balances[recipient].add(amount);
        emit Transfer(_cliente,recipient,amount);
        return true;
    }
    
    function approve (address delegate, uint amount) public override returns (bool) {
        allowed[msg.sender][delegate]=amount;
        emit Approval(msg.sender,delegate,amount);
        return true;
    }
    //TRANSFIERE TOKENS DELEGADOS A MI POR EL VENDEDOR HACIA EL COMPRADOR. SE RELACIONA CON LA FUNCION APPROVE
    function transferFrom(address owner, address buyer, uint amount) public override returns (bool) {
        require(amount<=balances[owner]);
        require(amount<=allowed[owner][msg.sender]);
        balances[owner]=balances[owner].sub(amount);
        allowed[owner][msg.sender]=allowed[owner][msg.sender].sub(amount);
        balances[buyer]=balances[buyer].add(amount);
        emit Transfer(owner,buyer,amount);
        return true;
    }
}