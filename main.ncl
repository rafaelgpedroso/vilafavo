<?xml version="1.0" encoding="iso-8859-1" ?>
<ncl id="exemplo">
<head>
	<regionBase>
		<region id="r1" left="0" top="0" width="100%" height="100%" />
		<region id="rgLua" left="0" top="0" width="100%" height="100%" />
	</regionBase>

	<descriptorBase>
		<descriptor id="d1" region="r1" />
		<descriptor id="dLua" region="rgLua" focusIndex="lua" />
	</descriptorBase>

	<connectorBase>
		<causalConnector id="onBeginAttributionStart">
			<simpleCondition role="onBeginAttribution" />
			<simpleAction role="start" max="unbounded" qualifier="par" />
		</causalConnector>

		<causalConnector id="onBeginAttributionStopStart">
			<simpleCondition role="onBeginAttribution" />
			<compoundAction operator="par">
				<simpleAction role="stop" max="unbounded" qualifier="par" />
				<simpleAction role="start" max="unbounded" qualifier="par" />
			</compoundAction>
		</causalConnector>

		<causalConnector id="onEndAttributionStop">
			<simpleCondition role="onEndAttribution" />
			<simpleAction role="stop" />
		</causalConnector>
	</connectorBase>
</head>

<body id="main">
  	<port id="p1" component="lua" />
	
  	<media id="lua" src="main.lua" descriptor="dLua" >
		<property name="close"/>

		<property name="open" />
		<property name="bg" />

		<property name="open_bg" />
		<property name="bg_open" />

		<property name="mn_bg" />
		<property name="bg_mn" />
	</media>

	<media id="programSettings" type="application/x-ginga-settings">
	<property name="service.currentKeyMaster" value="lua"/>
	</media>

	<media id="open" src="audio/open.mp3" />
	<media id="bg" src="audio/bg.mp3" />
	<media id="mn" src="audio/mn.mp3" />

	<link xconnector="onEndAttributionStop">
		<bind role="onEndAttribution" component="lua" interface="close"/>
		<bind component="main" role="stop" />
    </link>

	<link xconnector="onBeginAttributionStopStart">
		<bind role="onBeginAttribution" component="lua" interface="open"/>
		<bind role="stop" component="open"/>
		<bind role="start" component="open"/>
    </link>
	<link xconnector="onBeginAttributionStopStart">
		<bind role="onBeginAttribution" component="lua" interface="bg"/>
		<bind role="stop" component="bg"/>
		<bind role="start" component="bg"/>
    </link>

	<link xconnector="onBeginAttributionStopStart">
		<bind role="onBeginAttribution" component="lua" interface="mn_bg"/>
		<bind role="stop" component="mn"/>
		<bind role="start" component="bg"/>
    </link>
	<link xconnector="onBeginAttributionStopStart">
		<bind role="onBeginAttribution" component="lua" interface="bg_mn"/>
		<bind role="stop" component="bg"/>
		<bind role="start" component="mn"/>
    </link>
	
</body>

</ncl>
