package com.wb.software
{
	import flash.desktop.NativeApplication;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowDisplayState;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.NativeWindowBoundsEvent;
	import flash.events.NativeWindowDisplayStateEvent;
	
	public class WindowsMessenger extends WBMessenger
	{
		// stored objects
		private var m_caller :TestAppWindows = null;
		private var m_app    :TestApp        = null;
		private var m_ane    :WindowsANE     = null;
		private var m_data   :Object         = null;
		private var m_stage  :Stage          = null;
		private var m_window :NativeWindow   = null;
		
		// activated flag
		private var m_activated :Boolean = false;
		
		// default constructor
		public function WindowsMessenger(caller       :TestAppWindows,
										 swfWidth     :int,
										 swfHeight    :int,
										 swfFrameRate :int)
		{
			// defer to superclass
			super(swfWidth,
				  swfHeight,
				  swfFrameRate);
			
			// save caller
			m_caller = caller;
		}
		
		// send() -- override specific to this app
		override public function send(message :String, ...argv) :int
		{
			// verify app
			if(!m_app)
				return(0);
			
			// verify native extensions
			if(!m_ane)
				return(0);
			
			// verify data
			if(!m_data)
				return(0);
			
			// check message
			if(message)
			{
				// process message
				switch(message)
				{
				// getLongestDisplaySide()
				case("getLongestDisplaySide"):
					
					// return the value
					return(m_ane.getLongestDisplaySide());
					
				// maximize()
				case("maximize"):
					
					// tell the window
					m_window.maximize();
					
					// save changes
					onWindowChanged();
					
					// ok
					return(1);
					
				// messageBox()
				case("messageBox"):
						
					// check content
					if(argv.length != 2)
						break;
						
					// display message box
					m_ane.messageBox(argv[0] as String, argv[1] as String);
						
					// ok
					return(1);
					
				// quit()
				case("quit"):
					
					// terminate app
					NativeApplication.nativeApplication.exit();
					
					// ok
					return(1);
					
				// toggleFullScreen()
				case("toggleFullScreen"):
					
					// pass it on (using saved size & pos)
					m_ane.toggleFullScreen(m_data.windowPosX,
										   m_data.windowPosY,
										   m_data.windowWidth,
										   m_data.windowHeight);
					
					// save changes
					onWindowChanged();
					
					// ok
					return(1);
				}
			}
			
			// throw error
			throw new Error("com.wb.software.WindowsMessenger.send(): " +
				"Internal message cannot be sent due to invalid data: "+
				message);
			
			// failed
			return(0);
		}
		
		// onAddedToStage() -- callback to set initial position of app window
		public function onAddedToStage(e: Event) :void
		{
			// verify caller
			if(!m_caller)
				return;

			// get app
			m_app = m_caller.getApp();
			
			// verify app
			if(!m_app)
				return;
			
			// get native extensions
			m_ane = m_caller.getANE();
			
			// verify native extensions
			if(!m_ane)
				return;

			// get shared data
			m_data = m_app.sharedData();
			
			// verify data
			if(!m_data)
				return;

			// get stage
			m_stage = m_app.getStage();

			// verify stage
			if(!m_stage)
				return;

			// get main window
			m_window = m_stage.nativeWindow;
			
			// verify window
			if(!m_window)
				return;

			// check for valid window position data
			if(m_data.windowPosSet)
			{
				// retrieve saved size & pos
				var xTarget :int = m_data.windowPosX;
				var yTarget :int = m_data.windowPosY;
				var wTarget :int = m_data.windowWidth;
				var hTarget :int = m_data.windowHeight;
				
				// get desktop bounds
				var desktopL :int = m_ane.getDesktopLeft  (xTarget, yTarget, wTarget, hTarget);
				var desktopR :int = m_ane.getDesktopRight (xTarget, yTarget, wTarget, hTarget);
				var desktopT :int = m_ane.getDesktopTop   (xTarget, yTarget, wTarget, hTarget);
				var desktopB :int = m_ane.getDesktopBottom(xTarget, yTarget, wTarget, hTarget);
				
				// check left edge
				if(xTarget < desktopL)
				{
					// move onto screen
					xTarget = desktopL;
					
					// check new right edge
					if((xTarget + wTarget) >= desktopR)
					{
						// compute new width
						wTarget -= (xTarget + wTarget) - desktopR;
					}
				}
				
				// check right edge
				if((xTarget + wTarget) >= desktopR)
				{
					// move onto screen
					xTarget -= (xTarget + wTarget) - desktopR; 
					
					// check new left edge
					if(xTarget < desktopL)
					{
						// compute new width
						wTarget -= desktopL - xTarget;
						
						// move onto screen
						xTarget = desktopL;
					}
				}
				
				// check top edge
				if(yTarget < desktopT)
				{
					// move onto screen
					yTarget = desktopT;
					
					// check new bottom edge
					if((yTarget + hTarget) >= desktopB)
					{
						// compute new height
						hTarget -= (yTarget + hTarget) - desktopB;
					}
				}
				
				// check bottom edge
				if((yTarget + hTarget) >= desktopB)
				{
					// move onto screen
					yTarget -= (yTarget + hTarget) - desktopB; 
					
					// check new top edge
					if(yTarget < desktopT)
					{
						// compute new height
						hTarget -= desktopT - yTarget;
						
						// move onto screen
						yTarget = desktopT;
					}
				}
					
				// set new target size & pos
				m_window.x      = xTarget;
				m_window.y      = yTarget;
				m_window.width  = wTarget;
				m_window.height = hTarget;
			}
			else
			{
				// save starting size & pos
				onWindowChanged();
			}
			
			// add desktop window activate listener
			m_window.addEventListener(Event.ACTIVATE, onWindowActivate);
			
			// add desktop window size/pos listeners
			m_window.addEventListener(NativeWindowBoundsEvent.MOVE,     onWindowMove);
			m_window.addEventListener(NativeWindowBoundsEvent.RESIZE,   onWindowResize);
			m_window.addEventListener(NativeWindowBoundsEvent.RESIZING, onWindowResizing);
			
			// add desktop state change listener
			m_window.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE,   onDisplayStateChange);
			m_window.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGING, onDisplayStateChanging);
		}

		// onDisplayStateChange() -- display state has just changed
		protected function onDisplayStateChange(e :NativeWindowDisplayStateEvent) :void
		{
			// restored from minimize?
			if(e.beforeDisplayState == NativeWindowDisplayState.MINIMIZED &&
			   e.afterDisplayState  == NativeWindowDisplayState.NORMAL    )
				m_app.renderResume();
		}
		
		// onDisplayStateChanging() -- display state is about to change
		protected function onDisplayStateChanging(e :NativeWindowDisplayStateEvent) :void
		{
			// minimizing?
			if(e.beforeDisplayState == NativeWindowDisplayState.NORMAL    &&
			   e.afterDisplayState  == NativeWindowDisplayState.MINIMIZED )
				m_app.renderPause();
		}
		
		// onWindowActivate() -- desktop window is being activated
		protected function onWindowActivate(e :Event) :void
		{
			// already activated?
			if(m_activated)
				return;
			
			// maximize if needed
			if(m_data.maximizedFlagSet)
				if(m_data.maximizedFlag)
					send("maximize");

			// set fullscreen if needed
			if(m_data.fullScreenFlagSet)
				if(m_data.fullScreenFlag)
					send("toggleFullScreen");
			
			// set activated flag
			m_activated = true;
		}
		
		// onWindowChanged() -- window has moved or resized
		public function onWindowChanged() :void
		{
			// save maximized flag
			m_data.maximizedFlag    = windowIsMaximized();
			m_data.maximizedFlagSet = true;
			
			// save full-screen flag
			m_data.fullScreenFlag    = m_ane.isFullScreen();
			m_data.fullScreenFlagSet = true;

			// ignore size of any but normal window
			if(windowIsMaximized()  ||
			   windowIsMinimized()  ||
			   m_ane.isFullScreen() )
				return;

			// save window size & pos
			m_data.windowPosX   = m_window.x;
			m_data.windowPosY   = m_window.y;
			m_data.windowWidth  = m_window.width;
			m_data.windowHeight = m_window.height;
			m_data.windowPosSet = true;
		}
		
		// onWindowMove() -- handle window-move event
		public function onWindowMove(e :NativeWindowBoundsEvent) :void
		{
			// save changes
			onWindowChanged();
		}
		
		// onWindowResize() -- handle window-resize event
		private function onWindowResize(e :NativeWindowBoundsEvent) :void
		{
			// let app know
			m_app.onResize(null);
			
			// save changes
			onWindowChanged();
		}
		
		// onWindowResizing() -- handle window-resizing event
		private function onWindowResizing(e :NativeWindowBoundsEvent) :void
		{
			// let app know
			m_app.onResize(null);
		}
		
		// windowIsMaximized() -- determine if window is currently maximized
		private function windowIsMaximized() :Boolean
		{
			// return as boolean flag
			return((m_window.displayState == NativeWindowDisplayState.MAXIMIZED) ? true : false);
		}
		
		// windowIsMinimized() -- determine if window is currently minimized
		private function windowIsMinimized() :Boolean
		{
			// return as boolean flag
			return((m_window.displayState == NativeWindowDisplayState.MINIMIZED) ? true : false);
		}
	}
}
