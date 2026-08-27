/**
 * @description       : 
 * @author            : Ritesh Kumar
 * @group             : 
 * @last modified on  : 02-02-2024
 * @last modified by  : Ritesh Kumar
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   02-02-2024   Ritesh Kumar   Initial Version
**/
@SuppressWarnings('PMD.ExcessivePublicCount, PMD.CyclomaticComplexity, PMD.FieldDeclarationsShouldBeAtStart, PMD.EmptyStatementBlock')
public virtual class TriggerHandler {
   /**
	 * Map of `handlerName` => times `run()` was invoked
	 */
	@TestVisible
	private static Map<String, LoopCount> loopCountMap;

	/**
	 * All bypassed handlers
	 */
	@TestVisible
	private static Set<String> bypassedHandlers;

	/**
	 * `true` if we bypass all triggers without checking the contents of `bypassedHandlers`
	 */
	@TestVisible
	private static Boolean globalBypass;

	/**
	 * `true` if we include a debug statement for limits
	 */
	@TestVisible
	private static Boolean showLimits;

	/**
	 * `true` if we include a debug statement for trigger entry and exit
	 */
	@TestVisible
	private static Boolean showDebug;

	/**
	 * The current triggerEvent of the trigger, overridable in tests
	 */
	@TestVisible
	private System.TriggerOperation triggerEvent;

	/**
	 * Is this class executing in trigger context?
	 * @author {@link [David Schach](https://github.com/dschach)}
	 */
	@TestVisible
	private Boolean isTriggerExecuting;

	/**
	 * This is the value that will be in the returned list or set when global bypass is active
	 */
	@TestVisible
	private static final String BYPASS_ALL_ALIAS = 'BypassAll';

	// static initialization variables
	static {
		loopCountMap = new Map<String, LoopCount>();
		bypassedHandlers = new Set<String>();
		globalBypass = false;
		showLimits = false;
		showDebug = false;
	}

	/**
	 * @description Basic constructor. Slower than the other one
	 * @see TriggerHandler.TriggerHandler[1]
	 * @example
	 * new AccountSampleTriggerHandler().run();
	 *  // (in Trigger Handler)
	 * public AccountSampleTriggerHandler) {
	 *   super('AccountSampleTriggerHandler');
	 *   this.newRecords = (List<Account>) Trigger.new;
	 *   this.oldRecords = (List<Account>) Trigger.old;
	 *   this.newRecordsMap = (Map<Id, Account>) Trigger.newMap;
	 *   this.oldRecordsMap = (Map<Id, Account>) Trigger.oldMap;
	 * }
	 */
	public TriggerHandler() {
		this.setTriggerContext();
	}

	/**
	 * @description Constructor with handler name to improve performance
	 * @param  handlerName The name of the handler
	 * @example
	 * new AccountSampleTriggerHandler('AccountSampleTriggerHandler').run();
	 * // (in Trigger Handler)
	 * public AccountSampleTriggerHandler('AccountSampleTriggerHandler') {
	 *   this.newRecords = (List<Account>) Trigger.new;
	 *   this.oldRecords = (List<Account>) Trigger.old;
	 *   this.newRecordsMap = (Map<Id, Account>) Trigger.newMap;
	 *   this.oldRecordsMap = (Map<Id, Account>) Trigger.oldMap;
	 * }
	 */
	public TriggerHandler(String handlerName) {
		this.handlerName = handlerName;
		this.setTriggerContext();
	}

	/**
	 * @description Main method that will be called during execution
	 * <br>See the sample trigger for the best way to set up your handler
	 * @example
	 * new AccountSampleTriggerHandler().run();
	 */
	public void run() {
		if (!validateRun()) {
			return;
		}

		// Do not throw an exception if we exceed the loop count - just stop executing
		if (!incrementCheckLoopCount()) {
			return;
		}

		if (showDebug) {
			System.debug(LoggingLevel.DEBUG, String.format('Entering {0}, fired {1}', new List<String>{ getHandlerName(), this.triggerEvent + '' })); // NOPMD
		}

		// dispatch to the correct handler method
		switch on this.triggerEvent {
			when BEFORE_INSERT {
				this.beforeInsert();
			}
			when BEFORE_UPDATE {
				this.beforeUpdate();
			}
			when BEFORE_DELETE {
				this.beforeDelete();
			}
			when AFTER_INSERT {
				this.afterInsert();
			}
			when AFTER_UPDATE {
				this.afterUpdate();
			}
			when AFTER_DELETE {
				this.afterDelete();
			}
			when AFTER_UNDELETE {
				this.afterUndelete();
			}
		}
		this.andFinally();

		if (showLimits) {
			System.debug(
				LoggingLevel.DEBUG,
				String.format(
					'{0} on {1} ({2}/{3} queries) and ({4}/{5} DML calls)',
					new List<String>{
						this.triggerEvent + '',
						getHandlerName(),
						Limits.getQueries() + '',
						Limits.getLimitQueries() + '',
						Limits.getDmlStatements() + '',
						Limits.getLimitDmlStatements() + ''
					}
				)
			); // NOPMD
		}
		if (showDebug) {
			System.debug(LoggingLevel.DEBUG, String.format('Exiting {0}, fired {1}', new List<String>{ getHandlerName(), this.triggerEvent + '' })); // NOPMD
		}
	}

	/**
	 * @description Limit the number of times this handler can be run before it fails silently
	 * <br>Returning `TriggerHandler` enables method chaining when used in a trigger
	 * @return      `TriggerHandler` enables method chaining
	 * @example
	 * this.setMaxLoopCount(5); // in handler
	 * AccountTriggerHandler.setMaxLoopCount(5); // in handler
	 * or
	 * new TriggerHandler().setMaxLoopCount(5).run(); // in trigger
	 */
	public TriggerHandler setMaxLoopCount(Integer max) {
		String handlerName = getHandlerName();
		if (!TriggerHandler.loopCountMap.containsKey(handlerName)) {
			TriggerHandler.loopCountMap.put(handlerName, new LoopCount(max));
		} else {
			TriggerHandler.loopCountMap.get(handlerName).setMax(max);
		}
		return this;
	}

	/**
	 * @description Removes the limit for the number of times we allow this class to run
	 */
	public void clearMaxLoopCount() {
		this.setMaxLoopCount(-1);
	}

	/**
	 * @description       Bypass by string
	 *
	 * @param handlerName Name of the handler to be bypassed
	 * @example TriggerHandler.bypass('AccountSampleTriggerHandler');
	 */
	public static void bypass(String handlerName) {
		TriggerHandler.bypassedHandlers.add(handlerName);
	}

	/**
	 * @description       Bypass by type/class. This is probably best for avoiding typos.
	 * @example
	 * TriggerHandler.bypass(AccountTriggerHandler.class);
	 */
	public static void bypass(Type handlerType) {
		TriggerHandler.bypass(handlerType.getName());
	}

	/**
	 * @description        Bypass by list, e.g. TriggerHandler.bypass(listOfHandlerStrings)
	 *
	 * @param handlerNames List of handlernames
	 */
	public static void bypass(List<String> handlerNames) {
		TriggerHandler.bypassedHandlers.addAll(handlerNames);
	}

	/**
	 * @description Bypass all handlers (clear bypassedHandlers to prevent confusion)
	 * @example
	 * TriggerHandler.bypassAll();
	 */
	public static void bypassAll() {
		TriggerHandler.bypassedHandlers.clear();
		globalBypass = true;
	}

	/**
	 * @description Bypass a specific handler by name
	 * @example
	 * TriggerHandler.clearBypass('AccountSampleTriggerHandler');
	 */
	public static void clearBypass(String handlerName) {
		if (TriggerHandler.bypassedHandlers.contains(handlerName)) {
			TriggerHandler.bypassedHandlers.remove(handlerName);
		}
	}

	/**
	 * @description Bypass a specific handler by type
	 *
	 * @param handlerType The class to be bypassed. Must end with ".class"
	 * @example
	 * TriggerHandler.clearBypass(AccountSampleTriggerHandler.class);
	 */
	public static void clearBypass(Type handlerType) {
		TriggerHandler.clearBypass(handlerType.getName());
	}

	/**
	 * @description         Bypass a list of handlers
	 *
	 * @param handlerNames List of Strings of handlers to bypass
	 * @example
	 * List<String> classList = ['AccountTriggerHandler','ContactTriggerHandler'];
	 * TriggerHandler.clearBypass(classList);
	 */
	public static void clearBypass(List<String> handlerNames) {
		for (String s : handlerNames) {
			clearBypass(s);
		}
	}

	/**
	 * @description       A handler is considered bypassed if it was bypassed, or all handlers have been bypassed
	 *
	 * @param handlerName The class name of the handler we are checking is bypassed
	 * @return            `Boolean` Is this handler bypassed?
	 * @example
	 * TriggerHandler.isBypassed('AccountTriggerHandler');
	 */
	public static Boolean isBypassed(String handlerName) {
		return (globalBypass || TriggerHandler.bypassedHandlers.contains(handlerName));
	}

	/**
	 * @description       A handler is considered bypassed if it was bypassed, or all handlers have been bypassed
	 *
	 * @since 2021
	 * @param handlerType The handler class we are checking is bypassed
	 * @return            `Boolean` Is this handler bypassed?
	 * @example
	 * TriggerHandler.isBypassed(AccountTriggerHandler.class);
	 */
	public static Boolean isBypassed(Type handlerType) {
		return (globalBypass || TriggerHandler.bypassedHandlers.contains(handlerType.getName()));
	}

	/**
	 * @description Return a list of the bypassed handlers
	 * <br>Though both Set and List allow contains(value), we include both methods for convenience
	 *
	 * @return      `List<String>` List of bypassed handlers
	 * @example
	 * TriggerHandler.bypassList();
	 */
	public static List<String> bypassList() {
		List<String> bypasses = new List<String>(TriggerHandler.bypassedHandlers);
		bypasses.sort();
		// bypassAll clears bypassedHandlers, so bypasses is empty here
		if (globalBypass) {
			bypasses.add(BYPASS_ALL_ALIAS);
		}

		return bypasses;
	}

	/**
	 * @description Return a Set of the bypassed handlers
	 * <br>Though both Set and List allow contains(value), we include both methods for convenience
	 * @return      `Set<String>` Set of bypassed handlers
	 * @example
	 * if(TriggerHandler.bypassSet().contains('AccountSampleTriggerHandler'){
	 *   // do something
	 * }
	 */
	public static Set<String> bypassSet() {
		Set<String> bypasses = new Set<String>(TriggerHandler.bypassedHandlers);
		// bypassAll clears bypassedHandlers, so bypasses is empty here
		if (globalBypass) {
			bypasses.add(BYPASS_ALL_ALIAS);
		}

		return bypasses;
	}

	/**
	 * @description Clear all bypasses - by clearing the global bypass and by clearing the list of bypassed handlers
	 * @example
	 * TriggerHandler.clearAllBypasses();
	 */
	public static void clearAllBypasses() {
		clearGlobalBypass();
		clearBypassList();
	}

	/**
	 * @description Clear only the global bypass flag, leaving the list of bypassed handlers intact
	 * <br>This is useful for keeping a base set of bypassed handlers intact for an entire operation
	 * @example
	 * TriggerHandler.clearGlobalBypass();
	 */
	public static void clearGlobalBypass() {
		globalBypass = false;
	}

	/**
	 * @description Clear the entire bypass list, but keep the global bypass flag intact
	 * <br>This is useful for resetting the list of handlers to bypass while maintaining global bypassing
	 * @example
	 * TriggerHandler.clearBypassList();
	 */
	public static void clearBypassList() {
		TriggerHandler.bypassedHandlers.clear();
	}

	/**
	 * @description Set bypass status to a specific value. Eliminates the need to know the current bypass status
	 * @example
	 * TriggerHandler.setBypass('AccountTriggerHandler', false);
	 * -or-
	 * Boolean isBypassed = TriggerHandler.isBypassed('AccountTriggerHandler');
	 * TriggerHandler.bypass('AccountTriggerHandler');
	 * // do something here
	 * TriggerHandler.setBypass('AccountTriggerHandler', isBypassed);
	 */
	public static void setBypass(String handlerName, Boolean desiredValue) {
		if (globalBypass) {
			if (desiredValue == true) {
				TriggerHandler.bypass(handlerName);
			} else if (desiredValue == false) {
				clearGlobalBypass();
				TriggerHandler.clearBypass(handlerName);
			}
		}
		if (TriggerHandler.isBypassed(handlerName)) {
			if (desiredValue == false) {
				TriggerHandler.clearBypass(handlerName);
			}
		} else {
			if (desiredValue == true) {
				TriggerHandler.bypass(handlerName);
			}
		}
	}

	// handle limits

	/**
	 * @description Instance method to show limits for just this trigger handler, allowing method chaining in the trigger.
	 * @see TriggerHandler.showLimits[0]
	 * @example
	 * new AccountSampleTriggerHandler.limits().run();
	 *
	 * @return      `TriggerHandler` returning this class enables method chaining
	 */
	public TriggerHandler limits() {
		showLimits();
		return this;
	}

	/**
	 * @description Instance method to show/hide limits for just this trigger handler, allowing method chaining  in the trigger.
	 * @see TriggerHandler.showLimits[1]
	 * @example
	 * new AccountSampleTriggerHandler.limits(false).run();
	 *
	 * @param enabled true to enable; false to disable
	 * @return        `TriggerHandler` returning this class enables method chaining
	 */
	public TriggerHandler limits(Boolean enabled) {
		showLimits(enabled);
		return this;
	}

	/**
	 * @description Called before the trigger to force the class to debug query limits when it runs.
	 * <br>Use this in the trigger or handler
	 * @see TriggerHandler.showLimits[1]
	 * @example
	 * TriggerHandler.showLimits();
	 * new AccountSampleTriggerHandler.run();
	 * -or-
	 * AccountSampleTriggerHandler.showLimits();
	 */
	public static void showLimits() {
		showLimits(true);
	}

	/**
	 * @description   Called before the trigger to enable the class to debug (or not) query limits when it runs.
	 * <br>Set to true to show limits.
	 * <br>Use this in the trigger or handler
	 *
	 * @param enabled true to enable; false to disable
	 * @see TriggerHandler.showLimits[0]
	 */
	public static void showLimits(Boolean enabled) {
		if (enabled == null) {
			showLimits = false;
		} else if (enabled) {
			showLimits = true;
		} else {
			showLimits = false;
		}
	}

	// handle debugs

	/**
	 * @description Instance method to show debug logs for just this trigger handler, allowing method chaining in the trigger.
	 * @see TriggerHandler.showDebug[0]
	 * @example
	 * new AccountSampleTriggerHandler.debug().run();
	 *
	 * @return      `TriggerHandler` returning this class enables method chaining
	 */
	public TriggerHandler debug() {
		showDebug();
		return this;
	}

	/**
	 * @description Instance method to show debug logs for just this trigger handler, allowing method chaining in the trigger.
	 * @param enabled true to enable; false to disable
	 * @return      `TriggerHandler` returning this class enables method chaining
	 * @see TriggerHandler.showDebug[0]
	 * @example
	 * new AccountSampleTriggerHandler.debug().run();
	 */
	public TriggerHandler debug(Boolean enabled) {
		showDebug(enabled);
		return this;
	}

	/**
	 * @description Called in the trigger to force the class to debug trigger entry and exit with context.
	 * <br>Use this in the trigger or handler
	 * @example
	 * TriggerHandler.showDebug();
	 * new AccountSampleTriggerHandler.run(); // in trigger
	 * -or-
	 * AccountSampleTriggerHandler.showDebug(); // in handler
	 */
	public static void showDebug() {
		showDebug(true);
	}

	/**
	 * @description   Called in the trigger to force the class to debug trigger entry and exit with context. 
	 * @param enabled true to enable; false to disable
	 * @see TriggerHandler.showDebug[0]
	 */
	public static void showDebug(Boolean enabled) {
		if (enabled == null) {
			showDebug = false;
		} else if (enabled) {
			showDebug = true;
		} else {
			showDebug = false;
		}
	}

	/**
	 * @description       return the current loop count
	 * @param handlerName The handler class to check for the current loop count
	 * @return            `Integer` How many times has this handler run?
	 */
	public static Integer getLoopCount(String handlerName) {
		if (TriggerHandler.loopCountMap.containsKey(handlerName)) {
			return TriggerHandler.loopCountMap.get(handlerName).getCount();
		}
		return 0;
	}

	/**
	 * @description Base method called by constructor to set the current context
	 */
	@TestVisible
	private void setTriggerContext() {
		this.setTriggerContext(Trigger.operationType, false);
	}

	/**
	 * @description    Set the current trigger context based on the System.TriggerOperation
	 * <br>If we are not in a trigger context, then we set isTriggerExecuting to false
	 * <r>A single line is not covered by tests because we do not "fool" the handler into
	 * thinking that `Trigger.isExecuting` is true when we are running our tests. This line
	 * would be covered by any trigger handler in the org (and is the reason we include a
	 * sample handler for assistance when creating a package for this project)
	 *
	 * @param opType   The operation type - set automatically by the system
	 * @param testMode Only used in test methods to force certain contexts
	 * @see TriggerHandler.isTriggerExecuting
	 */
	@TestVisible
	private void setTriggerContext(System.TriggerOperation opType, Boolean testMode) {
		if (!Trigger.isExecuting && !testMode) {
			this.isTriggerExecuting = false;
			return;
		} else {
			this.isTriggerExecuting = true;
		}

		if (Trigger.isExecuting && !testMode) {
			// line not covered by TriggerHandlerTest
			this.triggerEvent = Trigger.operationType;
		}

		String context = opType?.name();

		switch on context {
			when 'BEFORE_INSERT' {
				this.triggerEvent = System.TriggerOperation.BEFORE_INSERT;
			}
			when 'BEFORE_UPDATE' {
				this.triggerEvent = System.TriggerOperation.BEFORE_UPDATE;
			}
			when 'BEFORE_DELETE' {
				this.triggerEvent = System.TriggerOperation.BEFORE_DELETE;
			}
			when 'AFTER_INSERT' {
				this.triggerEvent = System.TriggerOperation.AFTER_INSERT;
			}
			when 'AFTER_UPDATE' {
				this.triggerEvent = System.TriggerOperation.AFTER_UPDATE;
			}
			when 'AFTER_DELETE' {
				this.triggerEvent = System.TriggerOperation.AFTER_DELETE;
			}
			when 'AFTER_UNDELETE' {
				this.triggerEvent = System.TriggerOperation.AFTER_UNDELETE;
			}
			when else {
				// we are not in trigger context
				this.isTriggerExecuting = false;
			}
		}
	}

	/**
	 * @description Increment the loop count and check if we exceeded the max loop count. 
	 * @return   `Boolean` Should the trigger continue execution?
	 */
	private Boolean incrementCheckLoopCount() {
		String handlerName = getHandlerName();
		if (TriggerHandler.loopCountMap.containsKey(handlerName)) {
			Boolean exceeded = TriggerHandler.loopCountMap.get(handlerName).increment();
			if (exceeded) {
				/* Integer max = TriggerHandler.loopCountMap.get(handlerName).max;
				 throw new TriggerHandlerException('Maximum loop count of ' + String.valueOf(max) + ' reached in ' + handlerName); */
				if (showDebug) {
					Integer max = TriggerHandler.loopCountMap.get(handlerName).max;
					System.debug(logginglevel.INFO, 'Maximum loop count of ' + String.valueOf(max) + ' reached in ' + handlerName);
				}
				return false;
			}
			return true;
		}
		return true;
	}

	/**
	 * @description Make sure this trigger should continue to run
	 * <br>Returning `false` causes trigger handler to exit
	 *
	 * @return      `Boolean` Is the run valid?
	 * @exception   TriggerHandlerException
	 * @see TriggerHandler.TriggerHandlerException
	 */
	@TestVisible
	private Boolean validateRun() {
		if (!this.isTriggerExecuting || this.triggerEvent == null) {
			throw new TriggerHandlerException(ERROR_TRIGGERCONTEXT);
		}
		return (!globalBypass && !TriggerHandler.bypassedHandlers.contains(getHandlerName()));
	}

	/**
	 * @description The name of this handler. Set by `getHandlerName()`
	 */
	private String handlerName;

	/**
	 * @description Get the name of the current handler. This can be set by using the constructor with the string parameter to improve performance
	 *
	 * @return      `String` Name of the current handler
	 * @see         TriggerHandler.handlerName
	 */
	@TestVisible
	private String getHandlerName() {
		if (String.isBlank(this.handlerName)) {
			this.handlerName = this.toString().substringBefore(':');
		}
		return this.handlerName;
	}

	//triggerEvent methods

	/**
	 * @description Virtual method for the implementing class to override
	 */
	@TestVisible
	protected virtual void beforeInsert() {
	}

	/**
	 * @description Virtual method for the implementing class to override
	 */
	@TestVisible
	protected virtual void beforeUpdate() {
	}

	/**
	 * @description Virtual method for the implementing class to override
	 */
	@TestVisible
	protected virtual void beforeDelete() {
	}

	/**
	 * @description Virtual method for the implementing class to override
	 */
	@TestVisible
	protected virtual void afterInsert() {
	}

	/**
	 * @description Virtual method for the implementing class to override
	 */
	@TestVisible
	protected virtual void afterUpdate() {
	}

	/**
	 * @description Virtual method for the implementing class to override
	 */
	@TestVisible
	protected virtual void afterDelete() {
	}

	/**
	 * @description Virtual method for the implementing class to override
	 */
	@TestVisible
	protected virtual void afterUndelete() {
	}

	/**
	 * @description `andFinally` is called in every context, regardless of Trigger context
	 * */
	@TestVisible
	protected virtual void andFinally() {
	}

	// inner classes

	/**
	 * @description Inner class for managing the loop count per handler
	 */
	@TestVisible
	private class LoopCount {
		/**
		 * Maximum number of times this handler should be run
		 */
		private Integer max;
		/**
		 * Number of times this handler has been run
		 */
		private Integer count;

		/**
		 * Standard constructor
		 * <br>Default max to 5
		 * <br>Default count to 0
		 */
		public LoopCount() {
			this.max = 5;
			this.count = 0;
		}

		/**
		 * @description Constructor with specified max loops
		 *
		 * @param max   Max number of loops allowed
		 */
		public LoopCount(Integer max) {
			this.max = max;
			this.count = 0;
		}

		/**
		 * @description Increment the internal counter returning the results of
		 * this.exceeded().
		 * @return     `Boolean` true if count will exceed max count or is less
		 * than 0.
		 */
		public Boolean increment() {
			this.count++;
			return this.exceeded();
		}

		/**
		 * @description Determines if we're about to exceed the loop count.
		 * @return     `Boolean` True if less than 0 or more than max.
		 */
		public Boolean exceeded() {
			return this.max >= 0 && this.count > this.max;
		}

		/**
		 * @description Returns the max loop count.
		 * @return     `Integer` Max loop count.
		 */
		public Integer getMax() {
			return this.max;
		}

		/**
		 * @description Returns the current loop count.
		 * @return     `Integer` Current loop count.
		 */
		public Integer getCount() {
			return this.count;
		}

		/**
		 * @description Sets the max loop count
		 * @param max   The integer to set max to.
		 */
		public void setMax(Integer max) {
			this.max = max;
		}
	}

	/**
	 * @description Exception class
	 */
	public class TriggerHandlerException extends Exception {
	}

	/**
	 * @description Error text - assumes English for debug logs
	 */
	@TestVisible
	private static final String ERROR_TRIGGERCONTEXT = 'Trigger handler called outside of Trigger execution'; //NOPMD
}