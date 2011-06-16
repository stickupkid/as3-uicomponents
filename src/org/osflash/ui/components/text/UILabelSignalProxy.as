package org.osflash.ui.components.text
{
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	import org.osflash.ui.components.component.UIComponentSignalProxy;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class UILabelSignalProxy extends UIComponentSignalProxy
	{
		
		private const _textChanged : ISignal = new Signal(String);
		
		public function get textChanged() : ISignal { return _textChanged; }
	}
}