/* Copyright (C) wighawag <wighawag@gmail.com> - All Rights Reserved */
pragma solidity 0.4.18;

import "Bot.sol";

contract ExampleBot is Bot {

	function execute(bytes32[10] mworld, uint8 x, uint8 y, uint8 dir, uint8 other_x, uint8 other_y, uint8 other_dir, uint16 turn) public returns(uint8 dirChange){
		if(turn % 4 == 0){
			return 0;
		}else{
			return 2;
		}
		
	}
	
}

