//
//  StateFlow.swift
//  StateMachine
//
//  Created by Valentin Knabel on 19.02.15.
//  Copyright (c) 2015 Valentin Knabel. All rights reserved.
//

/// Represents a configuration of a state machine.
public struct StateFlow<T: Hashable> {
    
    /// Filters wether a transition is allowed to be performed.
    public typealias TransitionFilter = (Transition<T>) -> Bool
    /// Configures the instance for immutable usage.
    public typealias Configurator = (inout StateFlow<T>) -> Void
    
    /// Empty array means transition is allowed. Once there is a single filter, all previous unconditioned transitions are omitted.
    private var transitionFilters: [Transition<T>:TransitionFilter?] = [:]
    
    /**
    Creates a new instance that can be mutated to be stored immutable.
    
    :param: config A function that mutates the constructed instance.
    */
    public init(config: Configurator) {
        config(&self)
    }
    
    /// Creates a new instance to be used mutable.
    public init() { }
    
    /** 
    Allows all less-equal general transitions to be triggered.
    
    :param: transition The transition allowing less-equal transitions.
    :param: filter An optional filter for transitions.
    */
    public mutating func allowTransitions(transition: Transition<T>, filter: TransitionFilter? = nil) {
        if transitionFilters[transition] == nil {
            transitionFilters[transition] = filter
        }
    }
    
    /** 
    Returns wether a specific transition is allowed or not.
    Invokes defined transition filters until one returned true or a transition is unconditioned.
    
    :param: transition The transition to be tested.
    :returns: Returns true if a more-equal transition is allowed.
    */
    public func allowsTransition(transition: Transition<T>) -> Bool {
        for t in transition.generalTransitions {
            if let opf = transitionFilters[transition] {
                let succ = opf?(transition) ?? true
                if succ {
                    return true
                }
            }
        }
        return false
    }
    
}

public extension StateFlow {
    
    /**
    Convinience method that allows all less-equal general absolute transitions to be triggered.
    
    :param: from The source state.
    :param: to The target state.
    :param: filter An optional filter for transitions.
    */
    public mutating func allowTransitions(#from: T, to: T, filter: TransitionFilter? = nil) {
        self.allowTransitions(Transition<T>(from: from, to: to), filter: filter)
    }
    
    /**
    Convinience method that allows all less-equal general absolute transitions to be triggered.
    @param from All source states.
    @param to The target state.
    @param filter An optional filter for transitions.
    */
    public mutating func allowTransitions(#from: [T], to: T, filter: TransitionFilter? = nil) {
        for f in from {
            self.allowTransitions(Transition<T>(from: f, to: to), filter: filter)
        }
    }
    
    /**
    Convinience method that allows all less-equal general absolute transitions to be triggered.
    @param from The source state.
    @param to All target states.
    @param filter An optional filter for transitions.
    */
    public mutating func allowTransitions(#from: T, to: [T], filter: TransitionFilter? = nil) {
        for t in to {
            self.allowTransitions(Transition<T>(from: from, to: t), filter: filter)
        }
    }
    
    /**
    Convinience method that allows all less-equal general absolute transitions to be triggered.
    @param from All source states.
    @param to All target states.
    @param filter An optional filter for transitions.
    */
    public mutating func allowTransitions(#from: [T], to: [T], filter: TransitionFilter? = nil) {
        for f in from {
            for t in to {
                self.allowTransitions(Transition<T>(from: f, to: t), filter: filter)
            }
        }
    }
    
}

