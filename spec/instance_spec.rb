require File.expand_path('../spec_helper', __FILE__)
module HAProxyManager
  describe Instance do
    before(:all) do
      @stat_response = ["# pxname,svname,qcur,qmax,scur,smax,slim,stot,bin,bout,dreq,dresp,ereq,econ,eresp,wretr,wredis,status,weight,act,bck,chkfail,chkdown,lastchg,downtime,qlimit,pid,iid,sid,throttle,lbtot,tracked,type,rate,rate_lim,rate_max,check_status,check_code,check_duration,hrsp_1xx,hrsp_2xx,hrsp_3xx,hrsp_4xx,hrsp_5xx,hrsp_other,hanafail,req_rate,req_rate_max,req_tot,cli_abrt,srv_abrt,",
        "foo-farm,preprod-app,0,9,0,60,60,137789,34510620,3221358490,,0,,3,720,0,0,UP,12,1,0,562,143,45394,255790,,1,1,1,,113890,,2,0,,88,L7OK,200,20,0,134660,2028,147,230,0,0,,,,20,6,",
       "foo-farm,preprod-bg,0,0,0,3,30,31,14333,380028,,0,,0,9,4,2,DOWN,5,1,0,4,10,2453494,4518397,,1,1,2,,6,,2,0,,2,L4CON,,0,0,16,0,0,0,0,0,,,,1,0,",
       "foo-farm,preprod-test,0,0,0,0,30,0,0,0,,0,,0,0,0,0,DOWN,5,1,0,0,1,5017534,5017534,,1,1,3,,0,,2,0,,0,L4CON,,0,0,0,0,0,0,0,0,,,,0,0,",
       "foo-https-farm,preprod-app,0,0,0,3,60,6219,2577996,71804141,,0,,1,30,3,0,UP,12,1,0,559,137,45394,255774,,1,2,1,,1948,,2,0,,2,L7OK,200,109,0,5912,181,11,29,0,0,,,,501,0,",
       "foo-https-farm,preprod-bg,0,0,0,0,30,0,0,0,,0,,0,0,0,0,DOWN,5,1,0,4,4,2453494,4518368,,1,2,2,,0,,2,0,,0,L4CON,,0,0,0,0,0,0,0,0,,,,0,0,", 
       "foo-https-farm,preprod-test,0,0,0,0,30,0,0,0,,0,,0,0,0,0,DOWN,5,1,0,0,1,5017532,5017532,,1,2,3,,0,,2,0,,0,L4CON,,0,0,0,0,0,0,0,0,,,,0,0,"]
    end
    before(:each) do
      HAPSocket.any_instance.expects(:execute).returns(@stat_response)
      @instance = Instance.new("foo")
    end

    describe "creation" do
      it "parses stats and lists backends" do
        @instance.backends.size.should == 2
        @instance.backends.should include "foo-farm"
        @instance.backends.should include "foo-https-farm"
      end

      it "parses stats and lists servers" do
        @instance.servers('foo-farm').size.should == 3
      end
      it "understands servers without backend are all servers" do
        @instance.servers.size.should == 6
        @instance.servers.should include "preprod-bg"
        @instance.servers.should include "preprod-test"
      end
    end
    
    describe "enables servers" do
      it "enables a server" do
        HAPSocket.any_instance.expects(:exec).with('enable server foo-farm/preprod-bg')
        @instance.enable("preprod-bg", "foo-farm")
      end

      it "enables a all servers in multiple backends" do
        HAPSocket.any_instance.expects(:exec).with('enable server foo-farm/preprod-bg')
        HAPSocket.any_instance.expects(:exec).with('enable server foo-https-farm/preprod-bg')
        @instance.enable("preprod-bg")
      end

      it "disables a server" do
        HAPSocket.any_instance.expects(:exec).with('disable server foo-farm/preprod-bg')
        @instance.disable("preprod-bg", "foo-farm")
      end

      it "disables a server in all backends" do
        HAPSocket.any_instance.expects(:exec).with('disable server foo-farm/preprod-bg')
        HAPSocket.any_instance.expects(:exec).with('disable server foo-https-farm/preprod-bg')
        @instance.disable("preprod-bg")
      end
    end
  end
end