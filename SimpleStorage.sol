
// SPDX-License-Identifier: MIT
// pragma solidity >=0.8.18 <0.9.0;
 
pragma solidity ^0.8.24;

contract SimpleStorage {
    // the default visibility is internal
    // implicitly is created as a Storage variable
    // any variable created outside of a function is Storage variable
    uint256 public myFavoriteNumber; // default value is 0

    // uint256[] listOfFavoriteNumbers;
    // struct = my own types
    struct Person {
        uint256 favoriteNumber;
        string name;
    }

    // Person public pat = Person({ favoriteNumber: 7, name: "Pat" });
    // Person public mariah = Person({ favoriteNumber: 16, name: "Mariah" });

    // dynamic size - any size
    Person[] public listOfPeople;

    mapping(string => uint256) public nameToFavoriteNumber;

    // static array of 3 items max
    // Person[] public listOfPeople;

    function store(uint256 _favoriteNumber) public {
        myFavoriteNumber = _favoriteNumber;
    }

    // view, pure = don't run transaction, reads state from blockchain, 
    // don't cost gas except when a gas cost transaction is calling retrieve
    function retrieve() public view returns(uint256) {
        return myFavoriteNumber;
    }

    // temp variables: "calldata" and "memory" only exits in the function call
    // "calldata" vs "memory" a "memory" variable can be change, but a "calldata" and "storage" can't
    // "calldata", "memory"
    function addPerson(string memory _name, uint256 _favoriteNumber) public {
        listOfPeople.push( Person(_favoriteNumber, _name) );
        nameToFavoriteNumber[_name] = _favoriteNumber;
    }
}
