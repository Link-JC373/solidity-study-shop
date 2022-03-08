// SPDX-License-Identifier: MIT
pragma solidity >=0.6.21;

contract EcommerceStore {
    enum ProductStatus {
        Open,
        Sold,
        UnSold
    }
    enum ProductCondition {
        New,
        Used
    }

    uint256 public productIndex;
    mapping(address => mapping(uint256 => Product)) stores;
    mapping(uint256 => address) productIdInStore; // 产品id 关联 哪个用户

    struct Product {
        uint256 id;
        string name;
        string category;
        string imageLink;
        string descLink;
        uint256 auctionStartTime; // 拍卖开始时间
        uint256 auctionEndTime; // 拍卖结束时间
        uint256 totalBids;
        uint256 startPrice; // 起拍价格
        address highestBidder; // 最高出价人
        uint256 highestBid;
        uint256 secondHighestBid;
        ProductStatus status;
        ProductCondition condition;
        mapping(address => mapping(bytes32 => Bid)) bids;
    }

    struct Bid {
        address bidder;
        uint256 productId;
        uint256 value;
        bool revealed;
    }

    constructor() {
        productIndex = 0;
    }

    function addProductToStore(
        string memory _name,
        string memory _category,
        string memory _imageLink,
        string memory _descLink,
        uint256 _auctionStartTime,
        uint256 _auctionEndTime,
        uint256 _startPrice,
        uint256 _productCondition
    ) public {
        require(_auctionStartTime < _auctionEndTime);
        productIndex += 1;
        Product storage product = stores[msg.sender][productIndex];
        product.name = _name;
        product.category = _category;
        product.imageLink = _imageLink;
        product.descLink = _descLink;
        product.auctionStartTime = _auctionStartTime;
        product.auctionEndTime = _auctionEndTime;
        product.startPrice = _startPrice;
        product.condition = ProductCondition(_productCondition);
        product.status = ProductStatus.Open;
        product.highestBidder = address(0);
        product.highestBid = 0;
        product.secondHighestBid = 0;
        product.totalBids = 0;
        productIdInStore[productIndex] = msg.sender;
    }

    function getProduct(uint256 _productId)
        public
        view
        returns (
            uint256,
            string memory,
            string memory,
            string memory,
            string memory,
            uint256,
            uint256,
            uint256,
            ProductStatus,
            ProductCondition
        )
    {
        Product storage product = stores[productIdInStore[_productId]][
            _productId
        ];
        return (
            product.id,
            product.name,
            product.category,
            product.imageLink,
            product.descLink,
            product.auctionStartTime,
            product.auctionEndTime,
            product.startPrice,
            product.status,
            product.condition
        );
    }

    function bid(uint256 _productId, bytes32 _bid)
        public
        payable
        returns (bool)
    {
        Product storage product = stores[productIdInStore[_productId]][
            _productId
        ];
        require(block.timestamp >= product.auctionStartTime);
        require(block.timestamp <= product.auctionEndTime);
        require(msg.value > product.startPrice);
        require(product.bids[msg.sender][_bid].bidder == address(0));
        product.bids[msg.sender][_bid] = Bid(
            msg.sender,
            _productId,
            msg.value,
            false
        );
        product.totalBids += 1;
        return true;
    }

    function revealBid(
        uint256 _productId,
        string memory _amount,
        string memory _secret
    ) public {
        Product storage product = stores[productIdInStore[_productId]][
            _productId
        ];
        require(block.timestamp > product.auctionEndTime, "Still in bid");
        bytes32 sealedBid = keccak256(abi.encodePacked(_amount, _secret));
        Bid memory bidInfo = product.bids[msg.sender][sealedBid];
        require(bidInfo.bidder > address(0), "bidder not null");
        require(bidInfo.revealed == false, "bid has been deal");

        uint256 refund;
        uint256 amount = stringToUint(_amount);

        if (bidInfo.value < amount) {
            refund = bidInfo.value;
        } else {
            if (address(product.highestBidder) == address(0)) {
                product.highestBidder = msg.sender;
                product.highestBid = amount;
                product.secondHighestBid = product.startPrice;
                refund = bidInfo.value - amount;
            } else {
                if (amount > product.highestBid) {
                    product.secondHighestBid = product.highestBid;
                    payable(product.highestBidder).transfer(product.highestBid);
                    product.highestBidder = msg.sender;
                    product.highestBid = amount;
                    refund = bidInfo.value - amount;
                } else if (amount > product.secondHighestBid) {
                    product.secondHighestBid = amount;
                    refund = bidInfo.value;
                } else {
                    refund = bidInfo.value;
                }
            }
        }
        product.bids[msg.sender][sealedBid].revealed = true;

        if (refund > 0) {
            payable(msg.sender).transfer(refund);
        }
    }

    function highestBidderInfo(uint256 _productId)
        public
        view
        returns (
            address,
            uint256,
            uint256
        )
    {
        Product storage product = stores[productIdInStore[_productId]][
            _productId
        ];
        return (
            product.highestBidder,
            product.highestBid,
            product.secondHighestBid
        );
    }

    function totalBids(uint256 _productId) public view returns (uint256) {
        Product storage product = stores[productIdInStore[_productId]][
            _productId
        ];
        return product.totalBids;
    }

    function stringToUint(string memory s) private pure returns (uint256) {
        bytes memory b = bytes(s);
        uint256 result = 0;
        for (uint256 i = 0; i < b.length; i++) {
            if (b[i] >= 0x30 && b[i] <= 0x39) {
                result = result * 10 + (uint8(b[i]) - 48);
            }
        }
        return result;
    }
}
