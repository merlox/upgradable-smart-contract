pragma solidity ^0.5.0;

// 1. CHECK IF YOU CAN EXECUTE FUNCTIONS FROM THE OTHER CONTRACT WITH DELEGATECALL, yes
// 2. CHECK IF YOU CAN DINAMICALLY SEND THE FUNCTION TO EXECUTE WITH MSG.DATA AND CHECK IF STORAGE IS BEING UPDATED, yes
// 3. CHECK IF YOU CAN UPDATE THE STORAGE INFORMATION WHEN EXECUTING THE FUNCTION DINAMICALLY

// Where all the transactions go
contract Proxy {
    address public storageAddress;
    address public upgradableAddress;
    address public owner = msg.sender;

    address[] public listStorage; // To keep track of past storage contracts
    address[] public listUpgradable; // To keep track of past upgradable contracts

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    constructor() public {
        storageAddress = address(new Storage());
        upgradableAddress = address(new Upgradable(storageAddress));
        listStorage.push(storageAddress);
        listUpgradable.push(upgradableAddress);
    }

    function () external {
        bool isSuccessful;
        bytes memory message;
        (isSuccessful, message) = upgradableAddress.delegatecall(msg.data);

        require(isSuccessful);
    }

    function upgradeStorage(address _newStorage) public onlyOwner {
        require(storageAddress != _newStorage);
        storageAddress = _newStorage;
        listStorage.push(_newStorage);
    }

    function upgradeUpgradable(address _newUpgradable) public onlyOwner {
        require(upgradableAddress != _newUpgradable);
        upgradableAddress = _newUpgradable;
        listUpgradable.push(_newUpgradable);
    }
}

// The storage of variables and data
contract Storage {
    uint256 public myNumber;
    function setMyNumber(uint256 _myNumber) public {
        myNumber = _myNumber;
    }
}

// The one that will be upgraded
contract Upgradable {
    address public storageAddress;

    constructor (address _storageAddress) public {
        storageAddress = _storageAddress;
    }

    function setMyNumberStorage(uint256 _number) public {
        Storage s = Storage(storageAddress);
        s.setMyNumber(_number);
    }
}
