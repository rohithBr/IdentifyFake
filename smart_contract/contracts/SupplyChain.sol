pragma solidity >=0.4.24;
// SPDX-License-Identifier: MIT

import "./AccessController/ManufacturerRole.sol";
import "./AccessController/RetailerRole.sol";
import "./AccessController/ConsumerRole.sol";
import "./Interfaces/Ownable.sol";

contract SupplyChain is Ownable, ManufacturerRole, RetailerRole, ConsumerRole {
    address CentralAuthority; //Owner of Contract

    enum State {
        ProducedByManufacturer, //1
        ForSaleByManufacturer, //2
        PurchasedByRetailer, //3
        ShippedByManufacturer, //4
        RecieveByRetailer, //5
        ForSaleByRetailer, //6
        PurchasedByConsumer //7
    }

    State constant defaultState = State.ProducedByManufacturer;

    struct Product {
        uint256 productId;
        address currentOwner;
        address Manufacturer;
        string ManufacturerName;
        address Retailer;
        address Consumer;
        uint256 currentPrice;
        State productStatus;
    }

    mapping(uint256 => Product) productsList;

    event ProducedByManufacturer(uint256 productId); //1
    event ForSaleByManufacturer(uint256 productId); //2
    event PurchasedByRetailer(uint256 productId); //3
    event ShippedByManufacturer(uint256 productId); //4
    event RecieveByRetailer(uint256 productId); //5
    event ForSaleByRetailer(uint256 productId); //6
    event PurchasedByConsumer(uint256 productId); //7

    modifier verifyCaller(address _address) {
        require(msg.sender == _address);
        _;
    }

    modifier paidEnough(uint256 _price) {
        require(msg.value >= _price);
        _;
    }

    modifier checkValue(uint256 _productId, address addressToFund) {
        uint256 _price = productsList[_productId].currentPrice;
        uint256 amountToReturn = msg.value - _price;
        _make_payable(addressToFund).transfer(amountToReturn);
        _;
    }

    modifier producedByManufacturer(uint256 _productId) {
        require(
            productsList[_productId].productStatus ==
                State.ProducedByManufacturer
        );
        _;
    }

    modifier forSaleByManufacturer(uint256 _productId) {
        require(
            productsList[_productId].productStatus ==
                State.ForSaleByManufacturer
        );
        _;
    }

    modifier purchasedByRetailer(uint256 _productId) {
        require(
            productsList[_productId].productStatus == State.PurchasedByRetailer
        );
        _;
    }

    modifier shippedByManufacturer(uint256 _productId) {
        require(
            productsList[_productId].productStatus ==
                State.ShippedByManufacturer
        );
        _;
    }

    modifier recieveByRetailer(uint256 _productId) {
        require(
            productsList[_productId].productStatus == State.RecieveByRetailer
        );
        _;
    }

    modifier forSaleByRetailer(uint256 _productId) {
        require(
            productsList[_productId].productStatus == State.ForSaleByRetailer
        );
        _;
    }

    modifier purchasedByConsumer(uint256 _productId) {
        require(
            productsList[_productId].productStatus == State.PurchasedByConsumer
        );
        _;
    }

    constructor() payable {
        CentralAuthority = msg.sender;
    }

    function kill() public {
        if (msg.sender == CentralAuthority) {
            address payable ownerAddressPayable = _make_payable(
                CentralAuthority
            );
            selfdestruct(ownerAddressPayable);
        }
    }

    function _make_payable(address x) internal pure returns (address payable) {
        return payable(address(uint160(x)));
    }

    function producedByManufacturerFunction(
        uint256 _productId,
        address _Manufacturer,
        string memory _ManufacturerName
    ) public onlyManufacturer {
        Product memory newProduct = Product(
            _productId,
            _Manufacturer,
            _Manufacturer,
            _ManufacturerName,
            address(0),
            address(0),
            0,
            State.ProducedByManufacturer
        );
        productsList[_productId] = newProduct;
        emit ProducedByManufacturer(_productId);
    }

    function forSaleByManufacturerFunction(uint256 _productId, uint256 _price)
        public
        onlyManufacturer
        forSaleByManufacturer(_productId)
        verifyCaller(productsList[_productId].currentOwner)
    {
        productsList[_productId].productStatus = State.ForSaleByManufacturer;
        productsList[_productId].currentPrice = _price;
        emit ForSaleByManufacturer(_productId);
    }

    function purchasedByRetailerFunction(uint256 _productId)
        public
        payable
        onlyRetailer
        forSaleByManufacturer(_productId)
        paidEnough(productsList[_productId].currentPrice)
        checkValue(_productId, msg.sender)
    {
        address payable ownerAddressPayable = _make_payable(
            productsList[_productId].Manufacturer
        );
        ownerAddressPayable.transfer(productsList[_productId].currentPrice);
        productsList[_productId].currentOwner = msg.sender;
        productsList[_productId].Retailer = msg.sender;
        productsList[_productId].productStatus = State.PurchasedByRetailer;

        emit PurchasedByRetailer(_productId);
    }

    function shippedByManufacturerFunction(uint256 _productId)
        public
        onlyManufacturer
        verifyCaller(productsList[_productId].Manufacturer)
        purchasedByConsumer(_productId)
    {
        productsList[_productId].productStatus = State.ShippedByManufacturer;
        emit ShippedByManufacturer(_productId);
    }

    function recieveByRetailerFunction(uint256 _productId)
        public
        onlyRetailer
        verifyCaller(productsList[_productId].currentOwner)
        shippedByManufacturer(_productId)
    {
        productsList[_productId].productStatus = State.RecieveByRetailer;
        emit RecieveByRetailer(_productId);
    }

    function forSaleByRetailerFunction(uint256 _productId, uint256 _price)
        public
        onlyRetailer
        verifyCaller(productsList[_productId].currentOwner)
        recieveByRetailer(_productId)
    {
        productsList[_productId].productStatus = State.ForSaleByRetailer;
        productsList[_productId].currentPrice = _price;

        emit ForSaleByManufacturer(_productId);
    }

    function purchasedByConsumerFunction(uint256 _productId)
        public
        payable
        onlyConsumer
        forSaleByRetailer(_productId)
        paidEnough(productsList[_productId].currentPrice)
        checkValue(_productId, msg.sender)
    {
        productsList[_productId].Consumer = msg.sender;
        address payable ownerAddressPayable = _make_payable(
            productsList[_productId].Retailer
        );
        ownerAddressPayable.transfer(productsList[_productId].currentPrice);
        productsList[_productId].currentOwner = msg.sender;
        productsList[_productId].productStatus = State.PurchasedByConsumer;

        emit PurchasedByConsumer(_productId);
    }
}