Class {
	#name : #BaselineOfSocketServer4Pharo,
	#superclass : #BaselineOf,
	#category : #BaselineOfSocketServer4Pharo
}

{ #category : #baselines }
BaselineOfSocketServer4Pharo >> baseline: spec [
	<baseline>

	spec for: #'common' do: [
		spec package: #SocketServer4Pharo ].

]
