////
////  ResolvedProtocols.swift
////  ResolvedLibrary
////
////  Created by Olami on 2025-07-13.
////
//
//import Foundation
//
//public protocol HelpCenterViewControllerDelegate: AnyObject {
//    func helpCenterViewController(_ controller: HelpCenterViewController, didSelectView view: HelpCenterView)
//    func helpCenterViewController(_ controller: HelpCenterViewController, didPerformSearch query: String)
//    func helpCenterViewController(_ controller: HelpCenterViewController, didEncounterError error: Error)
//}
//
//public enum HelpCenterView {
//    case home
//    case knowledgeBase
//    case tickets
//    case createTicket
//    case faq(String)
//}
//
//public protocol FAQListViewControllerDelegate: AnyObject {
//    func faqListViewController(_ controller: FAQListViewController, didSelectFAQ faq: FAQ)
//    func faqListViewController(_ controller: FAQListViewController, didEncounterError error: Error)
//}
//
//public protocol KnowledgeBaseViewControllerDelegate: AnyObject {
//    func knowledgeBaseViewController(_ controller: KnowledgeBaseViewController, didSelectArticle article: Article)
//    func knowledgeBaseViewController(_ controller: KnowledgeBaseViewController, didSelectCollection collection: Collection)
//    func knowledgeBaseViewController(_ controller: KnowledgeBaseViewController, didEncounterError error: Error)
//}
//
//public protocol TicketListViewControllerDelegate: AnyObject {
//    func ticketListViewController(_ controller: TicketListViewController, didSelectTicket ticket: Ticket)
//    func ticketListViewController(_ controller: TicketListViewController, didEncounterError error: Error)
//}
//
//public protocol TicketCreationViewControllerDelegate: AnyObject {
//    func ticketCreationViewController(_ controller: TicketCreationViewController, didCreateTicket ticket: Ticket)
//    func ticketCreationViewController(_ controller: TicketCreationViewController, didEncounterError error: Error)
//}
