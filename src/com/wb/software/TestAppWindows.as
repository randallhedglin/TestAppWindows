package com.wb.software 
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;

	[SWF(width="640", height="480", frameRate="60")]
	
	public final class TestAppWindows extends Sprite
	{
		// swf metadata values (must match above!)
		private const SWF_WIDTH     :int = 640;
		private const SWF_HEIGHT    :int = 480;
		private const SWF_FRAMERATE :int = 60;
		
		// stored objects
		private var m_app       :TestApp          = null;
		private var m_messenger :WindowsMessenger = null;
		private var m_ane       :WindowsANE       = null;
	
		// consants
		private const WINDOWS_TEST_CODE :int = 0x317D035;
		
		// launch image
		[Embed(source="../../../../LaunchImg.png", mimeType="image/png")]
		private var LaunchImage :Class;
		
		// default constructor
		public function TestAppWindows()
		{
			// defer to superclass
			super();
			
			// load launch image
			var launchImg :Bitmap = new LaunchImage();
			
			// create messenger
			m_messenger = new WindowsMessenger(this,
											   SWF_WIDTH,
											   SWF_HEIGHT,
											   SWF_FRAMERATE);
		
			// create main app
			m_app = new TestApp(this,
								m_messenger,
								WBEngine.OSFLAG_WINDOWS,
								true, // renderWhenIdle
								launchImg,
								true); // testMode
			
			// listen for added-to-stage
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
			
		// addNativeExtensions() -- get native extensions up & running
		private function addNativeExtensions() :Boolean
		{
			// create extensions
			m_ane = new WindowsANE();
			
			// perform test
			if(m_ane.testANE(WINDOWS_TEST_CODE) != WINDOWS_TEST_CODE)
			{
				// throw error
				throw new Error("com.wb.software.TestAppWindows.addNativeExtensions(): " +
								"ANE function test failed");
				
				// fail
				return(false);
			}
			
			// add full screen button
			m_ane.addFullScreenButton();
			
			// ok
			return(true);
		}
		
		// getANE() -- get reference to native extensions
		public function getANE() :WindowsANE
		{
			// return object
			return(m_ane);
		}
		
		// getApp() -- get reference to base app
		public function getApp() :TestApp
		{
			// return object
			return(m_app);
		}
		
		// onAddedToStage() -- callback for added-to-stage notification
		private function onAddedToStage(e :Event) :void
		{
			// verify app
			if(!m_app)
				return;
			
			// add native extensions
			m_app.goingNative = addNativeExtensions();
			
			// initialize app
			m_app.init();
			
			// pass to messenger
			m_messenger.onAddedToStage(e);
		}
	}
}
