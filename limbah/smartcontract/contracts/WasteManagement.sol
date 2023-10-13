// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

error WasteManagement__NotOwner();
error WasteManagement__NotAdmin();
error WasteManagement__CategoryNotAccepted();

contract WasteManagement {
    enum WasteCategory {
        Anorganic,
        Organic,
        Recyclable
    }

    struct Waste {
        uint256 id;
        string category;
        uint256 amountInKg;
        uint256 totalPrice;
    }

    mapping(address => mapping(uint256 => Waste)) public ownerWaste;
    mapping(address => uint256) ownerWasteCount;
    mapping(WasteCategory => string) wasteCategoryToName;
    mapping(string => uint256) public wasteCategoryPrice;
    mapping(string => bool) public acceptedWasteCategory;
    mapping(address => uint256) public balanceOf;
    mapping(address => bool) public isAdmin;
    address public immutable i_owner;

    event StoreWaste(
        address indexed sender,
        address indexed wasteOwner,
        uint256 indexed wasteId,
        string category,
        uint256 wasteQuantity,
        uint256 wasteTotalPrice
    );

    event UpdateWaste(
        address indexed sender,
        address indexed wasteOwner,
        uint256 indexed wasteId,
        string newCategory,
        uint256 newWasteQty,
        uint256 newWasteTotalPrice
    );

    event AddAdmin(address indexed sender, address addedAdmin);

    event RevokeAdmin(address indexed sender, address revokedAdmin);

    modifier onlyOwner() {
        if (msg.sender != i_owner) {
            revert WasteManagement__NotOwner();
        }
        _;
    }

    modifier onlyAdmin() {
        if (isAdmin[msg.sender] != true) {
            revert WasteManagement__NotAdmin();
        }
        _;
    }

    modifier checkCategory(string calldata _category) {
        if (acceptedWasteCategory[_category] != true) {
            revert WasteManagement__CategoryNotAccepted();
        }
        _;
    }

    constructor() {
        wasteCategoryToName[WasteCategory.Anorganic] = "Anorganic";
        wasteCategoryToName[WasteCategory.Organic] = "Organic";
        wasteCategoryToName[WasteCategory.Recyclable] = "Recyclable";

        wasteCategoryPrice[wasteCategoryToName[WasteCategory.Anorganic]] = 1;
        wasteCategoryPrice[wasteCategoryToName[WasteCategory.Organic]] = 2;
        wasteCategoryPrice[wasteCategoryToName[WasteCategory.Recyclable]] = 3;

        acceptedWasteCategory[
            wasteCategoryToName[WasteCategory.Anorganic]
        ] = true;
        acceptedWasteCategory[
            wasteCategoryToName[WasteCategory.Organic]
        ] = true;
        acceptedWasteCategory[
            wasteCategoryToName[WasteCategory.Recyclable]
        ] = true;

        i_owner = msg.sender;
        isAdmin[i_owner] = true;
    }

    function addAdmin(address _admin) external onlyOwner {
        isAdmin[_admin] = true;

        emit AddAdmin(msg.sender, _admin);
    }

    function revokeAdmin(address _admin) external onlyOwner {
        isAdmin[_admin] = true;

        emit RevokeAdmin(msg.sender, _admin);
    }

    function getWasteCategory() external view returns (string[3] memory) {
        return [
            wasteCategoryToName[WasteCategory.Anorganic],
            wasteCategoryToName[WasteCategory.Organic],
            wasteCategoryToName[WasteCategory.Recyclable]
        ];
    }

    function storeWaste(
        address _wasteOwner,
        string calldata _wasteCategory,
        uint256 _wasteQty
    ) external onlyAdmin checkCategory(_wasteCategory) {
        uint256 currentWasteId = getOwnerWasteCount();
        uint256 wasteTotalPrice = _wasteQty *
            wasteCategoryPrice[_wasteCategory];

        Waste memory waste = Waste(
            currentWasteId,
            _wasteCategory,
            _wasteQty,
            wasteTotalPrice
        );
        ownerWaste[_wasteOwner][currentWasteId] = waste;

        balanceOf[_wasteOwner] += wasteTotalPrice;

        ownerWasteCount[msg.sender]++;
        emit StoreWaste(
            msg.sender,
            _wasteOwner,
            currentWasteId,
            _wasteCategory,
            _wasteQty,
            wasteTotalPrice
        );
    }

    function updateWaste(
        address _wasteOwner,
        uint256 _wasteId,
        string calldata _wasteCategory,
        uint256 _wasteQty
    ) external onlyAdmin checkCategory(_wasteCategory) {
        Waste memory waste = ownerWaste[_wasteOwner][_wasteId];

        balanceOf[_wasteOwner] -= waste.totalPrice;

        waste.category = _wasteCategory;
        waste.amountInKg = _wasteQty;
        waste.totalPrice = _wasteQty * wasteCategoryPrice[_wasteCategory];

        ownerWaste[_wasteOwner][_wasteId] = waste;
        balanceOf[_wasteOwner] += waste.totalPrice;

        emit UpdateWaste(
            msg.sender,
            _wasteOwner,
            _wasteId,
            waste.category,
            waste.amountInKg,
            waste.totalPrice
        );
    }

    function getOwnerWasteCount() internal view returns (uint256) {
        return ownerWasteCount[msg.sender];
    }
}

/* 
    "0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2","Organic",10

    "0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2",0,"Organic",20
*/
