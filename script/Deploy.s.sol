// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/Diamond.sol";
import "../src/DiamondCutFacet.sol";
import "../src/DiamondLoupeFacet.sol";
import "../src/OwnershipFacet.sol";
import "../src/ERC20Facet.sol";
import "../src/IDiamondCut.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Deploy facets
        DiamondCutFacet diamondCutFacet = new DiamondCutFacet();
        DiamondLoupeFacet diamondLoupeFacet = new DiamondLoupeFacet();
        OwnershipFacet ownershipFacet = new OwnershipFacet();
        ERC20Facet erc20Facet = new ERC20Facet();

        // Deploy diamond
        Diamond diamond = new Diamond(msg.sender, address(diamondCutFacet));

        // Build cut struct
        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](3);

        // Add DiamondLoupeFacet
        bytes4[] memory loupeSelectors = new bytes4[](4);
        loupeSelectors[0] = diamondLoupeFacet.facets.selector;
        loupeSelectors[1] = diamondLoupeFacet.facetFunctionSelectors.selector;
        loupeSelectors[2] = diamondLoupeFacet.facetAddresses.selector;
        loupeSelectors[3] = diamondLoupeFacet.facetAddress.selector;
        cut[0] = IDiamondCut.FacetCut({
            facetAddress: address(diamondLoupeFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: loupeSelectors
        });

        // Add OwnershipFacet
        bytes4[] memory ownershipSelectors = new bytes4[](2);
        ownershipSelectors[0] = ownershipFacet.owner.selector;
        ownershipSelectors[1] = ownershipFacet.transferOwnership.selector;
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

        vm.stopBroadcast();

        // Log addresses
        console.log("DiamondCutFacet deployed at:", address(diamondCutFacet));
        console.log("DiamondLoupeFacet deployed at:", address(diamondLoupeFacet));
        console.log("OwnershipFacet deployed at:", address(ownershipFacet));
        console.log("ERC20Facet deployed at:", address(erc20Facet));
        console.log("Diamond deployed at:", address(diamond));
    }
}
