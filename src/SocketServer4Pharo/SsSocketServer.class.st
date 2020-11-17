Class {
	#name : #SsSocketServer,
	#superclass : #Object,
	#instVars : [
		'backlogSize',
		'connectionSocket',
		'isRunning',
		'isRunningLock',
		'port'
	],
	#classInstVars : [
		'uniqueInstance'
	],
	#category : #SocketServer4Pharo
}

{ #category : #accessing }
SsSocketServer class >> uniqueInstance [
	^ uniqueInstance ifNil: [ uniqueInstance := self new ]
]

{ #category : #accessing }
SsSocketServer >> backlogSize [
	^ backlogSize ifNil: [ 10 ]
]

{ #category : #accessing }
SsSocketServer >> backlogSize: anObject [
	backlogSize := anObject
]

{ #category : #initialization }
SsSocketServer >> initialize [
	super initialize.
	isRunningLock := Mutex new.
	self isRunning: false
]

{ #category : #private }
SsSocketServer >> interactAndCleanUp: interactionSocket [
	[ self interactUsing: interactionSocket ]
		ensure: [ interactionSocket closeAndDestroy ]
]

{ #category : #private }
SsSocketServer >> interactOnConnection [
	| interactionSocket |
	interactionSocket := connectionSocket waitForAcceptFor: 1 ifTimedOut: [ ^ self ].
	[ self interactAndCleanUp: interactionSocket ] fork
]

{ #category : #private }
SsSocketServer >> interactUsing: interactionSocket [
	| receivedData |
	receivedData := interactionSocket receiveDataTimeout: 5.
	receivedData trimRight crTrace.
	interactionSocket sendData: 'ECHO: ' , receivedData
]

{ #category : #accessing }
SsSocketServer >> isRunning [
^ isRunningLock critical: [ isRunning ]
]

{ #category : #accessing }
SsSocketServer >> isRunning: aBoolean [
	isRunningLock critical: [ isRunning := aBoolean ]
]

{ #category : #accessing }
SsSocketServer >> port [
	^ port ifNil: [ 9999 ]
]

{ #category : #accessing }
SsSocketServer >> port: anObject [
	port := anObject
]

{ #category : #private }
SsSocketServer >> serve [
	[ [ self isRunning ] whileTrue: [ self interactOnConnection ] ]
		ensure: [ connectionSocket closeAndDestroy ]
]

{ #category : #'starting/stopping' }
SsSocketServer >> start [
	isRunningLock critical: [ 
		self isRunning ifTrue: [ ^ self ].
		self isRunning: true ].
	connectionSocket := Socket newTCP.
	connectionSocket listenOn: self port backlogSize: self backlogSize.
	[ self serve ] fork
]

{ #category : #'starting/stopping' }
SsSocketServer >> stop [
	self isRunning: false
]
