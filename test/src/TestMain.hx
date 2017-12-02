
import web3.Web3;
import web3.contract.BotCompetition;
import web3.contract.Bot;
import web3.contract.ExampleBot;
import web3.contract.StraightBot;

class TestMain extends Web3Setup{

	var competition : BotCompetition;
	var bot1 : Bot;
	var bot2 : Bot;

	function onWeb3Ready(web3 : Web3){
		
		if(account == null){
			trace("ERROR", "need to have a privateKey in .pk");
			return;
		}

		trace("Account : " + account);

		// web3.eth.sendTransaction({from:account,to:account,value:new Wei("1"),gas:21000,gasPrice:gasPrice},function(err,txHash){
		// 	trace(err,txHash);
		// });

		BotCompetition.deploy(web3,{gas:2000000,from:account},function(error,txHash){
			if(error != null){
				reportError(error);
			}else{
				trace("txHash : " + txHash);	
			}
			
		},
		function(error,competition : BotCompetition){
			if(error != null){
				trace("ERROR",error);
			}else{
				trace("address : "  + competition.address);
				this.competition = competition;
				setup();
			}
		});
		// this.competition = BotCompetition.at(web3,new Address(Sys.args()[1]));
		// setupGame();
	}


	function createBot1(next : Dynamic -> Dynamic -> Void){
		ExampleBot.deploy(web3,{gas:2000000,from:account},function(error,txHash){
			if(error != null){
				next(error,null);
			}else{
				// next(null,bot);
			}
			
		},
		function(error,bot : ExampleBot){
			if(error != null){
				next(error,null);
			}else{
				next(null,bot);	
			}
		});
	}


	function createBot2(next : Dynamic -> Dynamic -> Void){
		StraightBot.deploy(web3,{gas:2000000,from:account},function(error,txHash){
			if(error != null){
				next(error,null);
			}else{
				// next(null,bot);
			}
			
		},
		function(error,bot : StraightBot){
			if(error != null){
				next(error,null);
			}else{
				next(null,bot);	
			}
		});
	}

	function setup(){

		createBot1(function(err,bot1){
			if(err != null){
				trace("ERROR bot 1",err);
			}else{
				createBot2(function(err,bot2){
					if(err != null){
						trace("ERROR bot 2",err);
					}else{
						competition.commit_to_test_setup(
						{
							worldId:"0xff",
							bot1_code:bot1.address,
							bot2_code:bot2.address
						},{{gas:2000000,from:account}},function(err,tx,nonce){
							if(err != null){
								trace("ERROR setup",err);
							}else{
								trace("setup done");
								displayWorld("0xff",run);
							}		
						});
					}
				});	
			}
			
		});
		
	}

	function run(){
		competition.commit_to_step(
		{
			worldId:"0xff"
		},{{gas:4000000,from:account}},function(err,tx,nonce){
			if(err != null){
				trace("ERROR step",err);
			}else{
				trace("run done");
			}		
		});
	}

	function displayWorld(worldId : String, done : Void -> Void){
		// var index = 0;

		competition.probe_getTenthOfTheWorld({worldId:worldId,index:0},{gas:200000},function(err,result){
			if(err != null){
				trace("ERROR displayWorld",err);
				done();
			}else{
				trace(result);
				// index = 9;
				competition.probe_getTenthOfTheWorld({worldId:worldId,index:9},{gas:200000},function(err,result2){
					if(err != null){
						trace("ERROR displayWorld",err);
						done();
					}else{
						trace(result2);
						done();
					}
					
				});
			}
			
		});
		
	}

	function show10th(result){
		trace(result);
	}


	function onWeb3Error(error : Dynamic){
		trace("ERROR", error);
	}
}