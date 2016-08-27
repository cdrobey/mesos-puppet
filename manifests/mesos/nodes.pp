## nodes.pp ##

include 'docker'
#include 'apt'



node 'ms01' {
	docker::image {'jplock/zookeeper':
	}
 	docker::run { 'zookeeper':
               image   => 'jplock/zookeeper',
               ports   => [ '2181:2181','2888:2888','3888:3888' ],
               env     => [ 'SERVER_ID=1', 
		     	    'ADDITIONAL_ZOOKEEPER_1=server.1=ms01:2888:3888',
		     	    'ADDITIONAL_ZOOKEEPER_2=server.2=ms02:2888:3888', ],
	       extra_parameters => [ '--net host' ],
	}
	docker::image {'mesosphere/mesos-master':
		image_tag => '0.28.0-2.0.16.ubuntu1404'
	}
	
 	docker::run { 'mesos-master':
               image   => 'mesosphere/mesos-master:0.28.0-2.0.16.ubuntu1404',
               ports   => [ '5050:5050' ],
               env     => [ 'MESOS_PORT=5050', 
		     	    'MESOS_ZK=zk://ms01:2181/mesos',
		     	    'MESOS_QUORUM=1',
		     	    'MESOS_REGISTRY=in_memory',
		     	    'MESOS_LOG_DIR=/var/log/mesos',
		     	    'MESOS_WORK_DIR=/var/tmp/mesos',
			    'MESOS_IP=10.1.1.21', ],
	 	volumes => [ '/tmp/log:/var/log/mesos', '/tmp/mesos:/var/tmp/mesos' ],
	       extra_parameters => [ '--net host' ],
	}
}
node 'ms02','ms03' {
	class { 'apt':
  		update => {
    			frequency => 'daily',
  		},
	}
	class{'mesos':
  		repo => 'mesosphere'
	}
	class{'mesos::slave':
		listen_address => $::ipaddress_eth0,
		zookeeper => [ '10.1.1.21' ],
		options   => {
    			'containerizers' => 'docker,mesos',
    			'hostname'       => $::fqdn,
  		}
	}
}
