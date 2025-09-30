// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Diamond.sol";
import "../src/DiamondCutFacet.sol";
import "../src/DiamondLoupeFacet.sol";
import "../src/OwnershipFacet.sol";
import "../src/ERC20Facet.sol";
import "../src/IDiamondCut.sol";
import "../src/IDiamondLoupe.sol";
import "../src/IERC173.sol";

contract DiamondERC20Test is Test {
    Diamond diamond;
    DiamondCutFacet diamondCutFacet;
    DiamondLoupeFacet diamondLoupeFacet;
    OwnershipFacet ownershipFacet;
    ERC20Facet erc20Facet;

    address owner = address(this);
    address user1 = address(0x1);
    address user2 = address(0x2);

    function setUp() public {
        // Deploy facets
        diamondCutFacet = new DiamondCutFacet();
        diamondLoupeFacet = new DiamondLoupeFacet();
        ownershipFacet = new OwnershipFacet();
        erc20Facet = new ERC20Facet();

        // Deploy diamond
        diamond = new Diamond(owner, address(diamondCutFacet));

        // Build cut struct
        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](3);

        // Add DiamondLoupeFacet
        bytes4[] memory loupeSelectors = new bytes4[](4);
        loupeSelectors[0] = IDiamondLoupe.facets.selector;
        loupeSelectors[1] = IDiamondLoupe.facetFunctionSelectors.selector;
        loupeSelectors[2] = IDiamondLoupe.facetAddresses.selector;
        loupeSelectors[3] = IDiamondLoupe.facetAddress.selector;
        cut[0] = IDiamondCut.FacetCut({
            facetAddress: address(diamondLoupeFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: loupeSelectors
        });

        // Add OwnershipFacet
        bytes4[] memory ownershipSelectors = new bytes4[](2);
        ownershipSelectors[0] = IERC173.owner.selector;
        ownershipSelectors[1] = IERC173.transferOwnership.selector;
        cut[1] = IDiamondCut.FacetCut({
            facetAddress: address(ownershipFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: ownershipSelectors
        });

        // Add ERC20Facet
        bytes4[] memory erc20Selectors = new bytes4[](11);
        erc20Selectors[0] = erc20Facet.totalSupply.selector;
        erc20Selectors[1] = erc20Facet.balanceOf.selector;
        erc20Selectors[2] = erc20Facet.transfer.selector;
        erc20Selectors[3] = erc20Facet.allowance.selector;
        erc20Selectors[4] = erc20Facet.approve.selector;
        erc20Selectors[5] = erc20Facet.transferFrom.selector;
        erc20Selectors[6] = erc20Facet.name.selector;
        erc20Selectors[7] = erc20Facet.symbol.selector;
        erc20Selectors[8] = erc20Facet.decimals.selector;
        erc20Selectors[9] = erc20Facet.mint.selector;
        erc20Selectors[10] = erc20Facet.init.selector;
        cut[2] = IDiamondCut.FacetCut({
            facetAddress: address(erc20Facet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: erc20Selectors
        });

        // Execute the cut
        IDiamondCut(address(diamond)).diamondCut(cut, address(0), "");

        // Initialize ERC20
        ERC20Facet(address(diamond)).init("DiamondToken", "DTK", 18);
    }

    function testOwner() public {
        assertEq(IERC173(address(diamond)).owner(), owner);
    }

    function testFacets() public {
        IDiamondLoupe.Facet[] memory facets = IDiamondLoupe(address(diamond)).facets();
        assertEq(facets.length, 4); // diamondCut, loupe, ownership, erc20
    }

    function testERC20Init() public {
        assertEq(ERC20Facet(address(diamond)).name(), "DiamondToken");
        assertEq(ERC20Facet(address(diamond)).symbol(), "DTK");
        assertEq(ERC20Facet(address(diamond)).decimals(), 18);
    }

    function testMint() public {
        ERC20Facet(address(diamond)).mint(user1, 1000);
        assertEq(ERC20Facet(address(diamond)).balanceOf(user1), 1000);
        assertEq(ERC20Facet(address(diamond)).totalSupply(), 1000);
    }

    function testTransfer() public {
        ERC20Facet(address(diamond)).mint(user1, 1000);
        vm.prank(user1);
        ERC20Facet(address(diamond)).transfer(user2, 500);
        assertEq(ERC20Facet(address(diamond)).balanceOf(user1), 500);
        assertEq(ERC20Facet(address(diamond)).balanceOf(user2), 500);
    }

    function testApproveAndTransferFrom() public {
        ERC20Facet(address(diamond)).mint(user1, 1000);
        vm.prank(user1);
        ERC20Facet(address(diamond)).approve(user2, 500);
        assertEq(ERC20Facet(address(diamond)).allowance(user1, user2), 500);

        vm.prank(user2);
        ERC20Facet(address(diamond)).transferFrom(user1, user2, 300);
        assertEq(ERC20Facet(address(diamond)).balanceOf(user1), 700);
        assertEq(ERC20Facet(address(diamond)).balanceOf(user2), 300);
        assertEq(ERC20Facet(address(diamond)).allowance(user1, user2), 200);
    }
}
