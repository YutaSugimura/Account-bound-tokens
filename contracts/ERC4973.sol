pragma solidity ^0.8.6;

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return interfaceId == type(IERC165).interfaceId;
    }
}

interface IERC721Metadata {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);
}

interface IERC4973 {
    event Attest(address indexed to, uint256 indexed tokenId);
    event Revoke(address indexed to, uint256 indexed tokenId);

    function balanceOf(address owner) external view returns (uint256);

    function ownerOf(uint256 tokenId) external view returns (address);

    function burn(uint256 tokenId) external;
}

abstract contract ERC4973 is ERC165, IERC721Metadata, IERC4973 {
    string private _name;
    string private _symbol;

    mapping(uint256 => address) private _owners;
    mapping(uint256 => string) private _tokenURIs;
    mapping(address => uint256) private _balances;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override
        returns (bool)
    {
        return
            interfaceId == type(IERC721Metadata).interfaceId ||
            interfaceId == type(IERC4973).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function ownerOf(uint256 tokenId)
        public
        view
        virtual
        override
        returns (address)
    {
        address owner = _owners[tokenId];
        require(owner != address(0), "ownerOf: token doesn't exist");
        return owner;
    }

    function balanceOf(address owner)
        public
        view
        virtual
        override
        returns (uint256)
    {
        require(
            owner != address(0),
            "balanceOf: address zero is not a valid owner"
        );
        return _balances[owner];
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    function _mint(
        address to,
        uint256 tokenId,
        string memory uri
    ) internal virtual returns (uint256) {
        require(!_exists(tokenId), "mint: tokenID exists");
        _balances[to] += 1;
        _owners[tokenId] = to;
        _tokenURIs[tokenId] = uri;
        emit Attest(to, tokenId);
        return tokenId;
    }

    function _burn(uint256 tokenId) internal virtual {
        address owner = ownerOf(tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];
        delete _tokenURIs[tokenId];

        emit Revoke(owner, tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(_exists(tokenId), "tokenURI: token doesn't exist");
        return _tokenURIs[tokenId];
    }

    function mint(
        address to,
        uint256 tokenId,
        string memory uri
    ) public virtual returns (uint256) {
        return _mint(to, tokenId, uri);
    }

    function burn(uint256 tokenId) public virtual override {
        require(msg.sender == ownerOf(tokenId), "burn: sender must be owner");
        _burn(tokenId);
    }
}

contract AccountBoundTokens is ERC4973 {
    constructor(string memory name_, string memory symbol_)
        ERC4973(name_, symbol_)
    {}
}
